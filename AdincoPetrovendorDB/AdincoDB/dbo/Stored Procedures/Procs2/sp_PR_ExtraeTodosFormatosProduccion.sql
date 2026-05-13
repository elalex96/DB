-- =============================================
-- Author:		Reyna Olvera
-- Create date: 19/08/2019
-- Description:
-- =============================================
CREATE PROCEDURE [dbo].[sp_PR_ExtraeTodosFormatosProduccion] --10061,3
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT IdFormatoProduccionAWS,
           CO.NumeroContrato AS Contrato,
           PL.NombrePagina AS TipoFormato,
           NombreArchivo,
           U.Nombre as Usuario,
           FP.CreadoEl,
           Bucket,
           Folder,
           UPPER(UUIDAmazon) AS UUIDAmazon,
           Meta
    FROM PR_FormatoProduccionAWS FP
        JOIN dbo.AP_PaginaLayout PL
            ON FP.IdTipoFormato = PL.idPagina
        JOIN dbo.CO_Contrato CO
            ON FP.IdContrato = CO.IdContrato
        JOIN dbo.AP_Usuario U
            ON FP.CreadoPor = U.UsuarioID
			ORDER BY CO.IdContrato

END;
