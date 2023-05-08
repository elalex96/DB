-- =============================================
-- Author:		Reyna Olvera
-- Create date:20/04/18
-- Description:	Solo extrae los entregabloes por contreato
-- =============================================
CREATE PROCEDURE [dbo].[EN_ExtraeEntregablesPorContrato]--3,10061,2
	@idContrato int,
	@idUsuario int,
	@idregulador int
AS
BEGIN

	SET NOCOUNT ON;
SELECT DISTINCT(EN.IdEntregable) as IdEntregable,CONCAT(EN.IdEntregable, ' - ', EN.Consecutivo, ' - ', EN.DocumentoEntregable) AS DocumentoEntregable 
 --SELECT *
FROM EN_InstanciasEntregable IE
    JOIN EN_ContratoEntregable CE
        ON CE.IdContratoEntregable = IE.IdContratoEntregable
           AND CE.IdContrato = @idContrato
    JOIN EN_Estatus E
        ON E.idEstatus = IE.Estatus
    JOIN CO_Contrato C
        ON C.IdContrato = CE.IdContrato
    JOIN EN_Entregable EN
        ON EN.IdEntregable = CE.IdEntregable
    JOIN dbo.CO_Regulador R
        ON R.IdRegulador = EN.IdRegulador
    JOIN dbo.EN_MarcoLegal M
        ON M.IdMarcoLegal = EN.IdMarcoLegal
WHERE IE.Estatus IN ( 10000, 10005 )
      AND CE.UsuarioElabora = @idUsuario
      AND (EN.IdRegulador = @idregulador)
      AND (CE.IdContrato = @idContrato);

--	SELECT EN.IdEntregable as IdEntregable, CONCAT(EN.IdEntregable, ' - ', EN.Consecutivo, ' - ', EN.DocumentoEntregable) 
--AS DocumentoEntregable 
--FROM EN_Entregable AS EN 
--INNER JOIN EN_ContratoEntregable AS CE ON EN.IdEntregable = CE.IdEntregable 
--WHERE (EN.IdRegulador = @IdRegulador) AND (CE.IdContrato = @IdContrato)

END