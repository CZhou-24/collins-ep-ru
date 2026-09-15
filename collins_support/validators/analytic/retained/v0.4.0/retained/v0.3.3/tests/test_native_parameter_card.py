"""Actual MG reader/card fixtures; Python tests, not native compilation."""
from pathlib import Path
import re
import unittest

import madgraph_checks as m


FIXTURES = Path(__file__).parent/'fixtures/madgraph_370'
BENCHMARKS = {('sminputs', 1): 1/m.ALPHA_EM,
              ('sminputs', 3): m.ALPHA_S,
              ('mass', 11): 0., ('mass', 2): 0., ('mass', 21): 0.}


def entries(card):
    block = None
    for index, line in enumerate(card.splitlines()):
        fields = line.split('#', 1)[0].split()
        if not fields:
            continue
        if fields[0].lower() == 'block':
            block = fields[1].lower()
        elif fields[0].lower() == 'decay':
            block = None
        elif block in ('sminputs', 'mass') and fields[0].isdigit():
            yield index, (block, int(fields[0])), fields[1]


class NativeParameterCardTests(unittest.TestCase):
    def setUp(self):
        self.original = (FIXTURES/'param_card.default.dat').read_text()
        self.reader = (FIXTURES/'lha_read.f').read_text().upper()
        # Extract the constraint from the genuine reader used in the failure.
        widths = re.findall(r'CHARACTER\*(\d+)\s+PARAM\(MAXPARA\),VALUE\(MAXPARA\)',
                            self.reader)
        self.assertEqual(widths, ['20', '20'])
        self.width = int(widths[0])

    def test_actual_reader_contract_and_original_failure(self):
        self.assertIn('READ(VALUE(I),*) VAR', self.reader)
        for value in (1/m.ALPHA_EM, m.ALPHA_S, 0.):
            with self.subTest(value=value):
                old = format(value, '.17e')
                self.assertGreater(len(old), self.width)
                # The archived native reproducer independently exercises this
                # same truncation and Fortran internal read. Here no compiler runs.
                with self.assertRaises(ValueError):
                    float(old[:self.width])

    def test_all_fixed_values_fit_and_round_trip_bit_for_bit(self):
        actual = {key: token for _, key, token in entries(m.parameter_card(self.original))
                  if key in BENCHMARKS}
        self.assertEqual(set(actual), set(BENCHMARKS))
        for key, value in BENCHMARKS.items():
            with self.subTest(key=key):
                self.assertLessEqual(len(actual[key]), self.width)
                self.assertEqual(float(actual[key]).hex(), value.hex())

    def test_complete_native_card_is_idempotent(self):
        once = m.parameter_card(self.original)
        self.assertEqual(m.parameter_card(once), once)

    def test_every_nonbenchmark_line_is_preserved(self):
        before = self.original.splitlines()
        after = m.parameter_card(self.original).splitlines()
        selected = {index for index, key, _ in entries(self.original) if key in BENCHMARKS}
        self.assertEqual(len(selected), 5)
        self.assertEqual(len(before), len(after))
        for index, (a, b) in enumerate(zip(before, after)):
            if index not in selected:
                self.assertEqual(a, b, 'Unrequested card change at line '+str(index+1))


if __name__ == '__main__':
    unittest.main()
