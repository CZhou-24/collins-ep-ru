"""Extend the Born specification from an explicit generated native inventory.

The inventory records names, roles and check meanings, never candidate answers.
Its absence cannot silently erase an existing NLO project definition.
"""
import json
import re


def virtual_comparison_checks():
    """New identities over producer-calculated residuals; no candidate answers."""
    checks = []
    for branch in ('generic', 'plus', 'minus'):
        suffix = '' if branch == 'generic' else '_'+branch
        for component in ('11_LL', '11_XX', '11_YY', '22_LL', '22_XX', '22_YY'):
            for power in ('m2', 'm1', 'p0'):
                key = f'r06/virtualComparison_{branch}_{component}_{power}{suffix}'
                checks.append(dict(
                    id=key.replace('/', '.')+'.check', kind='identity', stage='r06',
                    channel='Hqq', lhs=key, rhs=0,
                    reason='Calculated virtual linear-certificate minus direct complex-series '
                           f'Laurent coefficient, {branch} branch, with the explicit mu->muR '
                           'and branch-coordinate conversions saved in the originating certificate. '
                           'Separate 54-check follow-up to the reviewed 16416-check run.'))
    return checks


def extend(spec, root, engine, source):
    contract_file = engine/'inputs'/'native_contract.json'
    if not contract_file.exists():
        current = engine/'project.json'
        if current.exists():
            previous = json.loads(current.read_text())
            if (previous.get('exports') or previous.get('master_imports') or
                    any(c['stage'] != 'r00' for c in previous.get('checks', []))):
                raise RuntimeError('Refuse to erase NLO declarations: native_contract.json is missing')
        return False
    contract = json.loads(contract_file.read_text())
    if contract.get('schema') != 1 or not contract.get('checks') or not contract.get('exports'):
        raise ValueError('Incomplete native contract inventory')
    fixed = [
        ('real_geometry', 'sidis', 'common/s02_result/s02_result.wl', 'definitions',
         'Preserved real family propagators, positive-energy cuts, geometry and measure.'),
        ('real_archived_reductions', 'sidis', 'common/s04_result/s04_result.wl', 'definitions',
         'Archived cut reduction rules; fresh actual-target reductions are compared on their overlap.'),
        ('virtual_geometry', 'sidis', 'common/s09_result/s09_result.wl', 'definitions',
         'Canonical virtual families, propagator masses, chord permutations and archived overlap rules.'),
        ('virtual_topologies', 'sidis', 'Hqq/s05_result/s05_result.wl', 'definitions',
         'Saved diagram-to-loop-family maps, used with the actual fresh polarized numerator.'),
        ('portable_real_masters', 'engine', 'inputs/real-master-bank.wl', 'definitions',
         'Exact archived real master Laurent selections, endpoint/branch definitions and depth evidence; no new integration.'),
        ('portable_virtual_masters', 'engine', 'inputs/virtual-master-bank.wl', 'definitions',
         'Exact archived virtual real/imaginary Laurent selections with explicit principal-branch and coordinate maps.'),
        ('real_master_basis', 'engine', 'inputs/real-master-basis.wl', 'masters',
         'Exactly reconstructed function-basis coefficients of the actually required real master Laurent selections.'),
        ('virtual_master_basis', 'engine', 'inputs/virtual-master-basis.wl', 'masters',
         'Exactly reconstructed function-basis coefficients of the actually required virtual master Laurent selections.'),
        ('uu_scalar_representation', 'engine', 'inputs/uu-scalar-representation.wl', 'definitions',
         'Exact scalar representation of all 102 imported UU hard entries; additive partitions and full-function reconstruction proofs retained. Every fresh import is compared to it exactly; no new UU integration claimed.'),
        ('uu_literal_native', 'engine', 'references/uu-inclusive-native.json', 'reference',
         'Independent literal extraction from archived UU banks at an exact physical point; a reuse/conversion check, not a fresh UU derivation.'),
        ('jet_paper_source', 'engine', 'references/2311.00672v2/source/main.tex', 'definitions',
         'Pinned literal universal small-R standard-axis fragmenting-jet/TMD factorization and matching source.'),
        ('jet_literal_coefficients', 'engine', 'references/jet_matching.json', 'reference',
         'Independently entered literal finite jet coefficients from the pinned source with explicit distribution conversions.'),
        ('flavor_contract', 'sidis', 'numerics/s08_result', 'definitions',
         'Preserved independent inclusive flavor/charge luminosity contract.'),
    ]
    for args in fixed:
        source(*args)
    for stage in ('s08', 's10', 's12', 's14', 's15'):
        source('archived_'+stage, 'sidis', f'common/{stage}_result/{stage}_result.wl',
               'definitions', 'Preserved master definitions, expansion depth or renormalization input; see producing provenance records.')
    for index, path in enumerate(sorted((root/'SIDIS/common/s19_result/s19_virtual').rglob('s19_masters.wl')), 1):
        source('virtual_master_shard_'+str(index), 'sidis', str(path.relative_to(root/'SIDIS')),
               'definitions', 'Archived analytic virtual master series, explicitly reused with native branch/depth checks.')
    for kind, stage, job in (('real', 'r02', 'cut'), ('virtual', 'r05', 'virtual')):
        path = engine/'inputs'/f'{kind}-master-basis.wl'
        keys = sorted(set(re.findall(r'"(C[0-9]{5})"\s*->', path.read_text())))
        if not keys:
            raise ValueError('No exact master coefficient selectors: '+kind)
        spec['master_imports'][stage] = {job: dict(
            source=kind+'_master_basis', selections={key: ['values', key] for key in keys},
            orders={key: 0 for key in keys},
            definition='Exact epsilon-independent scalar coefficients of the recorded archived master Laurent selections. The parent bank preserves the integral measure, physical cuts or principal branch, coordinates and full function reconstruction. No hard answer is imported.',
            precision_evidence='Each selected scalar is already a specified Laurent coefficient, with no remaining regulator. Required parent expansion depth and quotient/product checks are retained in the portable bank and native producing evidence. No unknown higher coefficient is assigned zero.')}
    spec['checks'].extend(contract['checks'])
    spec['checks'].extend(virtual_comparison_checks())
    spec['exports'].update(contract['exports'])
    for channel, fields in contract.get('channels', {}).items():
        spec['channels'][channel].update(fields)
    spec['scope']['factorization_definition'] = (
        'Leading-power inclusive collinear hard production convolved with the standard-axis small-R '
        'semi-inclusive TMD fragmenting-jet function. Soft-subtracted symbolic TMD at '
        'zeta_J=(p_JT R)^2, explicit dx/x dz_J/z_J^2 and Breit measurement limits; '
        'a C0 J0 + a^2(C1 J0+C0 J1), a=alpha_s/(2Pi). Full native acceptance is reported separately.')
    return True
