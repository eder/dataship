import tsParser from '@typescript-eslint/parser';
import tsPlugin from '@typescript-eslint/eslint-plugin';

export default [
  {
    // This config applies to all JS/TS files except the ones specified in "ignores".
    files: ['**/*.{js,jsx,ts,tsx}'],
    ignores: [
      'eslint.config.js',
      'postcss.config.js',
      'tailwind.config.js',
      'vite.config.ts'
    ],
    languageOptions: {
      ecmaVersion: 2021,
      sourceType: 'module',
      parser: tsParser,
      parserOptions: {
        project: './tsconfig.json'
      },
      // Define global variables for browser and Node environments.
      globals: {
        window: 'readonly',
        document: 'readonly',
        process: 'readonly'
      }
    },
    plugins: {
      '@typescript-eslint': tsPlugin
    },
    rules: {
      // Disable explicit function return type warnings.
      '@typescript-eslint/explicit-function-return-type': 'off',
      semi: ['error', 'always']
    }
  }
];

