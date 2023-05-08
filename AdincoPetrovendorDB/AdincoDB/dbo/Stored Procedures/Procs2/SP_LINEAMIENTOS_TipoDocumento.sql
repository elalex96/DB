create PROCEDURE SP_LINEAMIENTOS_TipoDocumento
AS
BEGIN 
select 
		IdLineamientoTipoDocumento,Tipodocumento 
		from EN_LineamientoTipoDocumento
		order by Tipodocumento  asc
END