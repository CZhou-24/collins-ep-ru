"""Independent coefficient checks for Collins ep analytic exports.

Standard library only. No Python/Wolfram expression code is executed. A passing
coefficient comparison is not evidence that the coefficient has been derived.
Derivation provenance, Ward identities, reductions, and execution receipts must
be checked by the calling harness separately.
"""

from __future__ import annotations

import json
import math
import random
from typing import Any

SCHEMA = "collins-ep-analytic-export/v1"
MAX_NODES = 2048
MAX_DEPTH = 32
MAX_INTEGER = 2**53 - 1
MAX_SERIALIZED_BYTES = 131072
MAX_EXPONENT = 8
ATOL = 2.0e-11
RTOL = 2.0e-11

CONVENTIONS = {
    "born_hard": {
        "process": "massless_e_q_to_e_q",
        "polarization": "unpolarized_electron_transverse_proton",
        "invariants": "s>0,t<0,u<0,s+t+u=0",
        "normalization": "QED_charge_and_couplings_stripped",
        "spin_convention": "collins_ep_v0.3.0",
    },
    "spacelike_hard_one_loop": {
        "process": "massless_e_q_to_e_q",
        "quantity": "squared_hard_matching_coefficient",
        "expansion": "H_q=1+alpha_s/(2*pi)*h1+O(alpha_s^2)",
        "logarithm": "L=ln(mu^2/Q^2)",
        "scheme": "arXiv:2007.07281:Appendix_A:A1",
        "color": "CF=(Nc^2-1)/(2*Nc),retained_symbolically",
    },
}

EXPRESSION_KEYS = {
    "born_hard": {"H_UU", "H_UT"},
    "spacelike_hard_one_loop": {"h1"},
}
SYMBOLS = {
    "born_hard": {"s", "t", "u"},
    "spacelike_hard_one_loop": {"L", "CF", "pi"},
}


class ExportError(ValueError):
    """Malformed, unsupported, or numerically undefined export."""


def _is_integer(value: Any) -> bool:
    return type(value) is int


def _same_keys(value: Any, keys: set[str], where: str) -> None:
    if type(value) is not dict or set(value) != keys:
        raise ExportError(f"{where}: expected exactly keys {sorted(keys)}")


def _validate_tree(node: Any, allowed: set[str]) -> None:
    """Validate iteratively, limiting node count, nesting, and integer size."""
    pending = [(node, 0)]
    count = 0
    while pending:
        current, depth = pending.pop()
        count += 1
        if count > MAX_NODES or depth > MAX_DEPTH:
            raise ExportError("expression exceeds node/depth limits")
        if type(current) is not dict:
            raise ExportError("AST nodes must be objects")
        op = current.get("op")
        if op == "rat":
            _same_keys(current, {"op", "num", "den"}, "rat")
            num, den = current["num"], current["den"]
            if not _is_integer(num) or not _is_integer(den):
                raise ExportError("rational numerator/denominator must be integers")
            if abs(num) > MAX_INTEGER or not 0 < den <= MAX_INTEGER:
                raise ExportError("rational integer out of range or denominator not positive")
        elif op == "sym":
            _same_keys(current, {"op", "name"}, "sym")
            if type(current["name"]) is not str or current["name"] not in allowed:
                raise ExportError("unrecognized symbol")
        elif op in ("add", "mul"):
            _same_keys(current, {"op", "args"}, op)
            args = current["args"]
            if type(args) is not list or not 2 <= len(args) <= MAX_NODES:
                raise ExportError("add/mul requires 2 or more operands within node budget")
            pending.extend((item, depth + 1) for item in args)
        elif op == "pow":
            _same_keys(current, {"op", "base", "exp"}, "pow")
            if not _is_integer(current["exp"]) or abs(current["exp"]) > MAX_EXPONENT:
                raise ExportError("power exponent must be a bounded integer")
            pending.append((current["base"], depth + 1))
        else:
            raise ExportError("unsupported AST operation")


def validate_payload(payload: Any) -> str:
    """Validate an in-memory parsed JSON export and return its component."""
    _same_keys(payload, {"schema", "component", "conventions", "expressions"}, "export")
    if payload["schema"] != SCHEMA:
        raise ExportError("unrecognized schema")
    component = payload["component"]
    if type(component) is not str or component not in CONVENTIONS:
        raise ExportError("unrecognized component")
    if payload["conventions"] != CONVENTIONS[component]:
        raise ExportError("conventions do not match the frozen comparison convention")
    _same_keys(payload["expressions"], EXPRESSION_KEYS[component], "expressions")
    for expression in payload["expressions"].values():
        _validate_tree(expression, SYMBOLS[component])
    try:
        encoded = json.dumps(payload, allow_nan=False, ensure_ascii=True)
    except (ValueError, TypeError, RecursionError) as exc:
        raise ExportError("payload is not finite JSON") from exc
    if len(encoded.encode("ascii")) > MAX_SERIALIZED_BYTES:
        raise ExportError("export exceeds serialized byte limit")
    return component


def _reject_constant(value: str) -> None:
    raise ExportError(f"non-JSON numeric constant {value!r}")


def _unique_object(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result = {}
    for key, value in pairs:
        if key in result:
            raise ExportError("duplicate JSON object key")
        result[key] = value
    return result


def loads_export(text: str) -> dict[str, Any]:
    """Load bounded JSON, rejecting duplicate keys and NaN/Infinity."""
    if type(text) is not str or len(text.encode("utf-8")) > MAX_SERIALIZED_BYTES:
        raise ExportError("input must be bounded UTF-8 JSON text")
    try:
        payload = json.loads(text, parse_constant=_reject_constant,
                             object_pairs_hook=_unique_object)
    except (ValueError, TypeError, RecursionError) as exc:
        raise ExportError("invalid or unsupported JSON") from exc
    validate_payload(payload)
    return payload


def _finite(triple: tuple[float, float, float]) -> tuple[float, float, float]:
    if any(not math.isfinite(x) or abs(x) > 1.0e200 for x in triple):
        raise ExportError("nonfinite or excessively large expression result")
    return triple


def _evaluate(node: dict[str, Any], values: dict[str, float],
              wrt: str | None = None) -> tuple[float, float, float]:
    """Value, first derivative, second derivative from elementary dual algebra.

    Only call after validate_payload; the recursive walk has already been bounded.
    """
    op = node["op"]
    if op == "rat":
        return node["num"] / node["den"], 0.0, 0.0
    if op == "sym":
        name = node["name"]
        value = math.pi if name == "pi" else values[name]
        return value, float(name == wrt), 0.0
    if op == "add":
        terms = [_evaluate(arg, values, wrt) for arg in node["args"]]
        return _finite(tuple(math.fsum(term[i] for term in terms) for i in range(3)))
    if op == "mul":
        value, first, second = 1.0, 0.0, 0.0
        for arg in node["args"]:
            other, other_first, other_second = _evaluate(arg, values, wrt)
            value, first, second = _finite((
                value * other,
                first * other + value * other_first,
                second * other + 2 * first * other_first + value * other_second,
            ))
        return value, first, second
    base, first, second = _evaluate(node["base"], values, wrt)
    exponent = node["exp"]
    if exponent == 0:
        if base == 0:
            raise ExportError("zero to zeroth power is not accepted")
        return 1.0, 0.0, 0.0
    if exponent == 1:
        return base, first, second
    try:
        return _finite((
            base**exponent,
            exponent * base**(exponent-1) * first,
            exponent * (exponent-1) * base**(exponent-2) * first**2
            + exponent * base**(exponent-1) * second,
        ))
    except (ArithmeticError, ValueError) as exc:
        raise ExportError("undefined power in expression") from exc


def _check(check_id: str, actual: float, expected: float,
           detail: str = "") -> dict[str, Any]:
    error = abs(actual - expected)
    tolerance = ATOL + RTOL * abs(expected)
    return {
        "id": check_id, "status": "PASS" if error <= tolerance else "FAIL",
        "actual": actual, "expected": expected, "absolute_error": error,
        "tolerance": tolerance, "detail": detail,
    }


def _born_checks(expressions: dict[str, Any], seed: int) -> list[dict[str, Any]]:
    rng = random.Random(f"collins-ep-born-oracle-v1:{seed}")
    checks = []
    for index in range(18):
        s = 10.0**rng.uniform(-2, 5)
        y = [0.001, 0.5, 0.999][index] if index < 3 else rng.uniform(0.015, 0.985)
        t, u = -s*y, -s*(1-y)
        values = {"s": s, "t": t, "u": u}
        # Express references through y, independently of the export's invariant AST.
        targets = {"H_UU": 2*(1+(1-y)**2)/y**2, "H_UT": 4*(1-y)/y**2}
        for name, expected in targets.items():
            actual = _evaluate(expressions[name], values)[0]
            checks.append(_check(f"born/point-{index:02d}/{name}", actual, expected))
            # Euler identity for simultaneous scaling of Mandelstam invariants.
            euler = math.fsum(values[key] * _evaluate(expressions[name], values, key)[1]
                              for key in ("s", "t", "u"))
            checks.append(_check(f"born/point-{index:02d}/{name}-homogeneity",
                                 euler / max(1.0, abs(actual)), 0.0,
                                 "Euler derivative divided by max(1,|H|); dimensionless hard factor"))
    return checks


def _hard_checks(expressions: dict[str, Any], seed: int) -> list[dict[str, Any]]:
    rng = random.Random(f"collins-ep-hard-oracle-v1:{seed}")
    expression = expressions["h1"]
    checks = []
    for index in range(18):
        logarithm = [0.0, -1.5, 2.0][index] if index < 3 else rng.uniform(-5.0, 5.0)
        colors = (2, 3, 5)[index % 3]
        cf = (colors*colors - 1)/(2*colors)
        actual, first, second = _evaluate(expression, {"L": logarithm, "CF": cf}, "L")
        expected = cf * (-logarithm**2 - 3*logarithm - 8 + math.pi**2/6)
        checks.append(_check(f"hard/point-{index:02d}/h1", actual, expected))
        checks.append(_check(f"hard/point-{index:02d}/dL", first, cf*(-2*logarithm-3),
                             "Partial derivative at fixed CF; not a running-alpha_s RGE test"))
        checks.append(_check(f"hard/point-{index:02d}/dL2", second, -2*cf))
        color_first = _evaluate(expression, {"L": logarithm, "CF": cf}, "CF")[1]
        checks.append(_check(f"hard/point-{index:02d}/color", cf*color_first, actual,
                             "One-loop quark hard correction linear in CF"))
    return checks


def validate_export(payload: Any, seed: int = 1729) -> list[dict[str, Any]]:
    """Return schema and independent numerical checks, including any failure.

    Intended for coefficient exports only. The caller must independently verify
    derivation artifacts. A fabricated reference expression passes these checks.
    Withheld seeds must be chosen by the reviewer after production is frozen.
    """
    if not _is_integer(seed) or not 0 <= seed < 2**64:
        return [{"id": "export/seed", "status": "FAIL", "detail": "seed must be uint64"}]
    try:
        component = validate_payload(payload)
    except (ExportError, TypeError, ValueError, RecursionError) as exc:
        return [{"id": "export/schema", "status": "FAIL", "detail": str(exc)}]
    checks = [{"id": "export/schema", "status": "PASS", "detail": component}]
    try:
        checks.extend((_born_checks if component == "born_hard" else _hard_checks)(
            payload["expressions"], seed))
    except (ExportError, ArithmeticError, ValueError, TypeError, KeyError) as exc:
        checks.append({"id": "export/evaluation", "status": "FAIL", "detail": str(exc)})
    return checks
