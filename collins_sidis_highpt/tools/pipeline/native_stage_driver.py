#!/usr/bin/env python3
"""Native producing chain inside a runner-owned stage output directory.

The official runner executes Kira and master extraction after the stage packet.
This driver executes the actual Wolfram contraction/mapping helpers sequentially
and records each subprocess, including failures. Polarized outputs are freshly
produced; archived masters and the explicit UU representation are reused with
their recorded definition and complete-expression checks.
"""
import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path

from prepare_native_reduction import prepare
from native_process import run_owned

TOPOLOGIES = ('RealQGG', 'RealSame', 'RealDistinct', 'Hqqbar')


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def merge_maps(directories, output):
    output.mkdir()
    records = [json.loads((p/'kira-input.json').read_text()) for p in directories]
    merged = dict(records[0])
    for field in ('external', 'invariants', 'scalarproducts'):
        if any(r[field] != merged[field] for r in records):
            raise ValueError('Incompatible real map geometry: '+field)
    families, targets = {}, {}
    for record in records:
        for family in record['families']:
            name = family['id']
            if name in families and families[name] != family:
                raise ValueError('Different family definitions: '+name)
            families[name] = family
        for target in record['targets']:
            targets[(target['family'], tuple(target['powers']))] = target
    merged.update(families=[families[k] for k in sorted(families)],
                  targets=[targets[k] for k in sorted(targets)],
                  scope='Union of the four freshly generated polarized real target sets')
    (output/'kira-input.json').write_text(json.dumps(merged, indent=2)+'\n')
    (output/'map-identities.json').write_text(json.dumps({str(p): digest(p/'mapping.wl') for p in directories}, indent=2)+'\n')


def main():
    stage_parent = os.getppid()
    context_file = Path(os.environ['SIDIS_HIGHPT_CONTEXT'])
    ctx = json.loads(context_file.read_text())
    engine, out = Path(ctx['production']), Path(ctx['output'])
    inputs = {k: Path(v) for k, v in ctx['inputs'].items()}
    kernel = ctx['runtime']['wolfram_kernel']
    log = []

    def native(label, script, **settings):
        path = engine/'tools'/'pipeline'/script
        env = os.environ.copy()
        # Each call supplies its complete inputs. Never inherit a development
        # pair restriction, archived-output path or master override.
        for key in list(env):
            if key.startswith('SIDIS_') and key != 'SIDIS_HIGHPT_CONTEXT':
                env.pop(key)
        env.update(OPENBLAS_NUM_THREADS='1', OMP_NUM_THREADS='1', MKL_NUM_THREADS='1')
        env.update({k: str(v) for k, v in settings.items()})
        command = [kernel, '-noprompt', '-script', str(path)]
        logfile = out/(label+'.log')
        row = dict(label=label, command=command, settings={k: str(v) for k, v in settings.items()},
                   source_sha256=digest(path), status='RUNNING')
        log.append(row)
        (out/'native-driver.json').write_text(json.dumps(log, indent=2)+'\n')
        print('NATIVE_HELPER', label, flush=True)
        try:
            with logfile.open('x') as stream:
                result = run_owned(command, parent_pid=stage_parent, cwd=engine.parent,
                                   env=env, stdout=stream, stderr=subprocess.STDOUT)
        except BaseException as exc:
            row.update(status='INTERRUPTED', detail=str(exc), log_sha256=digest(logfile))
            (out/'native-driver.json').write_text(json.dumps(log, indent=2)+'\n')
            raise
        row.update(exit_code=result.returncode, log_sha256=digest(logfile), status='FINISHED')
        (out/'native-driver.json').write_text(json.dumps(log, indent=2)+'\n')
        if result.returncode:
            raise RuntimeError('First failing native helper: '+label+'; see '+str(logfile))
        if digest(path) != row['source_sha256']:
            raise RuntimeError('Producing source changed while running: '+str(path))

    def finalize_packet():
        # Exact arithmetic representation only. The raw producing packet stays
        # beside the final packet; no candidate value or formula is changed.
        raw = out/'packet-unpartitioned.wl'
        (out/'packet.wl').rename(raw)
        masters, nominal = {}, {}
        if sid in ('r03', 'r07'):
            masters['master/r02/cut/'] = str(inputs['r02']/'jobs'/'cut'/'masters.wl')
            nominal['master/r02/cut/'] = ctx['saved_inputs']['real_master_basis']['resolved']
        if sid in ('r06', 'r07'):
            masters['master/r05/virtual/'] = str(inputs['r05']/'jobs'/'virtual'/'masters.wl')
            nominal['master/r05/virtual/'] = ctx['saved_inputs']['virtual_master_basis']['resolved']
        cp = out/'certificate-transport-context.json'
        cp.write_text(json.dumps(dict(input=str(raw), output=str(out/'packet.wl'),
                                      masters=masters, nominal_banks=nominal,
                                      proof=str(out/'certificate-transport.wl'),
                                      summary=str(out/'certificate-transport.json'),
                                      attach_evidence=True), indent=2)+'\n')
        native('certificate-transport', 'refactor_native_packet.wls', SIDIS_CERTIFICATE_DAG_CONTEXT=cp)

    sid = ctx['stage']
    if sid == 'r00':
        # Fresh preparation within this same physical run, before the real
        # mapping stage. This keeps both stages within the unchanged limit.
        templates, projected = out/'RealQGG-templates', out/'RealQGG-projected'
        native('RealQGG-templates', 'real_template_continuation.wls',
               SIDIS_REAL_OUT=templates, SIDIS_REAL_TOPOLOGY='RealQGG')
        native('RealQGG-projected', 'project_collins_pairs.wls',
               SIDIS_TEMPLATE_INPUT=templates/'templates.wl', SIDIS_MAP_OUT=projected)
        return
    if sid == 'r01':
        maps = []
        for topology in TOPOLOGIES:
            preparation = inputs['r00'] if topology == 'RealQGG' else out
            templates, projected = [preparation/(topology+'-'+s) for s in ('templates', 'projected')]
            mapping = out/(topology+'-map')
            if topology != 'RealQGG':
                native(topology+'-templates', 'real_template_continuation.wls', SIDIS_REAL_OUT=templates, SIDIS_REAL_TOPOLOGY=topology)
            if topology == 'RealDistinct':
                native(topology+'-map', 'map_real_templates.wls', SIDIS_TEMPLATE_INPUT=templates/'templates.wl', SIDIS_MAP_OUT=mapping)
            else:
                if topology != 'RealQGG':
                    native(topology+'-projected', 'project_collins_pairs.wls', SIDIS_TEMPLATE_INPUT=templates/'templates.wl', SIDIS_MAP_OUT=projected)
                native(topology+'-map', 'map_collins_linear.wls', SIDIS_TEMPLATE_INPUT=templates/'templates.wl',
                       SIDIS_PROJECTED_PAIRS=projected, SIDIS_MAP_OUT=mapping)
            maps.append(mapping)
        native('qgg-gluon-ward', 'qgg_amplitude_ward.wls', SIDIS_QGG_WARD_OUT=out/'qgg-gluon-ward')
        combined = out/'combined-map'
        merge_maps(maps, combined)
        job = prepare(combined, out/'jobs'/'real', 'real', ['Hqq', 'Hqqbar'])
        (out/'jobs.json').write_text(json.dumps([job], indent=2)+'\n')
    elif sid == 'r02':
        job = json.loads((inputs['r01']/'jobs.json').read_text())[0]
        work = inputs['r01']/'jobs'/'real'
        for topology in TOPOLOGIES:
            native(topology+'-reduction', 'check_real_reduction.wls',
                   SIDIS_REAL_MAP=inputs['r01']/(topology+'-map'), SIDIS_REAL_KIRA=work,
                   SIDIS_KIRA_MASTER_INVENTORY=work/job['master_inventory'],
                   SIDIS_REAL_CHECK_OUT=out/(topology+'-reduction'))
    elif sid == 'r04':
        native('virtual-templates', 'virtual_template_continuation.wls', SIDIS_VIRTUAL_OUT=out/'templates')
        native('virtual-map', 'map_virtual_templates.wls', SIDIS_TEMPLATE_INPUT=out/'templates'/'templates.wl', SIDIS_MAP_OUT=out/'map')
        job = prepare(out/'map', out/'jobs'/'virtual', 'virtual', ['Hqq'], engine/'references'/'virtual-terminal-targets.txt')
        (out/'jobs.json').write_text(json.dumps([job], indent=2)+'\n')
    elif sid == 'r05':
        native('virtual-reduction', 'check_virtual_reduction.wls', SIDIS_VIRTUAL_MAP=inputs['r04']/'map',
               SIDIS_VIRTUAL_KIRA=inputs['r04']/'jobs'/'virtual', SIDIS_VIRTUAL_CHECK_OUT=out/'reduction')
    elif sid == 'r03':
        for topology in TOPOLOGIES:
            native(topology+'-linear', 'real_linear_certificates.wls',
                   SIDIS_REAL_REDUCTION=inputs['r02']/(topology+'-reduction')/'reduction.wl',
                   SIDIS_REAL_PORTABLE_INPUT=ctx['saved_inputs']['portable_real_masters']['resolved'],
                   SIDIS_EVALUATED_REAL_MASTERS=inputs['r02']/'jobs'/'cut'/'masters.wl',
                   SIDIS_MASTER_BASIS_INPUT=ctx['saved_inputs']['real_master_basis']['resolved'],
                   SIDIS_REAL_LINEAR_OUT=out/(topology+'-linear'))
        native('outgoing-collinear', 'general_collinear_templates.wls',
               SIDIS_QGG_TEMPLATES=inputs['r00']/'RealQGG-templates', SIDIS_BORN_DIRECTORY=inputs['r00'],
               SIDIS_COLLINEAR_OUT=out/'outgoing-collinear')
        native('incoming-collinear', 'initial_collinear_templates.wls',
               SIDIS_QGG_TEMPLATES=inputs['r00']/'RealQGG-templates', SIDIS_BORN_DIRECTORY=inputs['r00'],
               SIDIS_COLLINEAR_OUT=out/'incoming-collinear')
        native('tagged-operator', 'tagged_collinear_embedding.wls', SIDIS_COLLINEAR_OUT=out/'tagged-operator')
        native('virtual-operator', 'operator_virtual_scheme_check.wls', SIDIS_OPERATOR_VIRTUAL_OUT=out/'virtual-operator')
        native('scheme-match', 'collinear_scheme_match.wls',
               SIDIS_OUTGOING_COLLINEAR_INPUT=out/'outgoing-collinear'/'comparison.wl',
               SIDIS_INCOMING_COLLINEAR_INPUTS=out/'incoming-collinear'/'comparison.wl',
               SIDIS_TAGGED_OPERATOR_INPUT=out/'tagged-operator'/'embedding.wl',
               SIDIS_OPERATOR_VIRTUAL_INPUT=out/'virtual-operator'/'operator-virtual.wl',
               SIDIS_SCHEME_MATCH_OUT=out/'scheme-match')
        native('transversity-subtractions', 'transversity_subtractions.wls',
               SIDIS_BORN_INPUT=inputs['r00']/'born_tensor_dimensional.wl', SIDIS_SUBTRACTION_OUT=out/'subtractions')
    elif sid == 'r06':
        native('virtual-uv', 'virtual_uv_asymptotics.wls', SIDIS_VIRTUAL_MAP_INPUT=inputs['r04']/'map'/'mapping.wl',
               SIDIS_BORN_INPUT=inputs['r00']/'born_tensor_dimensional.wl', SIDIS_VIRTUAL_UV_OUT=out/'uv')
        native('direct-virtual', 'assemble_virtual_masters.wls', SIDIS_VIRTUAL_REDUCTION=inputs['r05']/'reduction'/'reduction.wl',
               SIDIS_BORN_INPUT=inputs['r00']/'born_tensor_dimensional.wl', SIDIS_VIRTUAL_UV_INPUT=out/'uv'/'uv.wl',
               SIDIS_VIRTUAL_ASSEMBLY_OUT=out/'direct-virtual')
        for sign, label in ((0, 'generic'), (1, 'plus'), (-1, 'minus')):
            # The same formulas and actual evaluated master input are used for
            # baseline and probes. Acceptance of calculated residuals belongs
            # to the official checker, not to this producing subprocess.
            native('virtual-linear-'+label, 'virtual_linear_certificates.wls',
                   SIDIS_VIRTUAL_ASSEMBLY_INPUT=out/'direct-virtual'/'virtual.wl',
                   SIDIS_VIRTUAL_PORTABLE_INPUT=ctx['saved_inputs']['portable_virtual_masters']['resolved'],
                   SIDIS_EVALUATED_VIRTUAL_MASTERS=inputs['r05']/'jobs'/'virtual'/'masters.wl',
                   SIDIS_MASTER_BASIS_INPUT=ctx['saved_inputs']['virtual_master_basis']['resolved'],
                   SIDIS_VIRTUAL_LINEAR_OUT=out/('linear-'+label), SIDIS_VIRTUAL_BRANCH=sign,
                   SIDIS_LINEAR_CHECK_COMPARISON='false')
    elif sid == 'r07':
        hard_cfg = dict(
            real=[str(inputs['r03']/(topology+'-linear')/'certificates.wl') for topology in TOPOLOGIES],
            virtual={label: str(inputs['r06']/('linear-'+label)/'certificates.wl') for label in ('plus', 'minus')},
            subtractions=str(inputs['r03']/'subtractions'/'subtractions.wl'),
            born=str(inputs['r00']/'born_tensor_dimensional.wl'),
            scheme=str(inputs['r03']/'scheme-match'/'scheme.wl'),
            real_masters=ctx['saved_inputs']['portable_real_masters']['resolved'],
            virtual_masters=ctx['saved_inputs']['portable_virtual_masters']['resolved'],
            output=str(out/'hard-recipes'))
        cp = out/'hard-recipes-context.json'
        cp.write_text(json.dumps(hard_cfg, indent=2)+'\n')
        native('hard-recipes', 'assemble_hard_recipes.wls', SIDIS_HARD_RECIPES_CONTEXT=cp)
        basis_cfg = dict(
            recipes=str(out/'hard-recipes'/'hard-recipes.wl'),
            real_basis=ctx['saved_inputs']['real_master_basis']['resolved'],
            virtual_basis=ctx['saved_inputs']['virtual_master_basis']['resolved'],
            real_evaluated=str(inputs['r02']/'jobs'/'cut'/'masters.wl'),
            virtual_evaluated=str(inputs['r05']/'jobs'/'virtual'/'masters.wl'),
            output=str(out/'hard-basis'))
        cp = out/'hard-basis-context.json'
        cp.write_text(json.dumps(basis_cfg, indent=2)+'\n')
        native('hard-basis', 'assemble_native_hard_compact.wls', SIDIS_NATIVE_HARD_CONTEXT=cp)
        native('UU-import', 'import_uu_channels.wls', SIDIS_UU_IMPORT_OUT=out/'UU')
        native('jet-TMD-RG', 'jet_tmd_rg_check.wls', SIDIS_JET_TMD_RG_OUT=out/'jet-TMD-RG')
        native('measured-actions', 'check_observable_actions.wls', SIDIS_ACTION_CHECK_OUT=out/'measured-actions')
        native('UU-scalars', 'reuse_uu_scalar_exports.wls',
               SIDIS_UU_REPRESENTATION_INPUT=ctx['saved_inputs']['uu_scalar_representation']['resolved'],
               SIDIS_UU_CURRENT_INPUT=out/'UU'/'uu-channels.wl', SIDIS_UU_SCALAR_OUT=out/'UU-scalars')
        native('finite-jet', 'jet_matching_check.wls', SIDIS_JET_CHECK_OUT=out/'finite-jet')
        native('flavors', 'check_flavor_contract.wls', SIDIS_FLAVOR_CHECK_OUT=out/'flavors')
        native('boundary', 'check_native_boundary_series.wls',
               SIDIS_NATIVE_HARD_INPUT=out/'hard-basis'/'native-hard.wl', SIDIS_NATIVE_BOUNDARY_OUT=out/'boundary')
        native('observable', 'assemble_native_observable.wls',
               SIDIS_NATIVE_HARD_INPUT=out/'hard-basis'/'native-hard.wl',
               SIDIS_UU_INPUT=out/'UU'/'uu-channels.wl', SIDIS_OBSERVABLE_OUT=out/'observable')
        native('packet', 'emit_native_final_packet.wls')
        finalize_packet()
        return
    else:
        raise ValueError('Native producing chain is not implemented for '+sid)
    native('packet', 'emit_native_mapping_packet.wls')
    if sid in ('r03', 'r06'):
        finalize_packet()


if __name__ == '__main__':
    main()
