import 'package:flutter/material.dart';

/// Colours of the NUNI logo (Q23): fixed, generic, deliberately NOT derived
/// from [Palette] -- the logo must read the same regardless of the active
/// palette. Source of truth: `web/icons/nuni_logo.svg`.
const Color nuniLogoNu = Color(0xFF2B2B2B);
const Color nuniLogoNi = Color(0xFF8A8A8A);

/// App icon background (Q23, `web/icons/Icon-*.png`): the off-white tile the
/// logo sits on wherever it appears as a mark, not just as the PWA icon.
const Color nuniLogoBackground = Color(0xFFF5F5F5);
