CREATE FUNCTION [dbo].[fnGetFechaElaboraRevisa]
(
	@IdContratoEntregable INT,
	@IdTipoOperacion int
)
RETURNS VARCHAR (2000)
AS
BEGIN
	DECLARE @FechaRet VARCHAR (2000) = ''
		set @FechaRet=(
			select top 1
				isnull(Convert(varchar,CreadoEn,1),'-') as 'FechaElaboracion' 
				from EN_HistorialAprobacionesLineaTiempo 
				where idinstanciaentregable=@IdContratoEntregable 
					and idtipooperacion = @IdTipoOperacion)
	RETURN @FechaRet 
END