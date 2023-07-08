CREATE TYPE [dbo].[TY_ListaCambioDiario] AS TABLE (
	[Fecha] DATE NULL,
	[TipoCambio] DECIMAL(18, 5) NULL
	);