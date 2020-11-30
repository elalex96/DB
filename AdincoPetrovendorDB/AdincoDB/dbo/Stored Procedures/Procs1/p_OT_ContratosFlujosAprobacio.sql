CREATE PROCEDURE p_OT_ContratosFlujosAprobacio
as
BEGIN
	select 
	FlujoAprobacionId,
	IdContrato,
	CreadoEl
		from AP_FlujoAprobacionContratos
END

