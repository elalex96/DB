USE Petrovendor;

  ALTER TABLE FacturasExcluirRestriccionAnioFiscal ADD AnioExclucion INT;

  ALTER TABLE FacturasExcluirRestriccionAnioFiscal ADD FechaVigencia DATETIME;

  ALTER TABLE FacturasExcluirRestriccionAnioFiscal ADD CreadoPor INT;

  ALTER TABLE FacturasExcluirRestriccionAnioFiscal ADD CreadoEl DATETIME;

  ALTER TABLE FacturasExcluirRestriccionAnioFiscal ADD ModificadoPor INT;

  ALTER TABLE FacturasExcluirRestriccionAnioFiscal ADD ModificadoEl DATETIME;