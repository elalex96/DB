CREATE PROCEDURE [dbo].[EN_ExtraeMarcoLegal]--10061,3
    @idUsuario INT,
    @idContrato INT
AS
BEGIN
    -- =================================================================
    -- Author:	Reyna Olvera
    -- Create date: 27/09/2019
    -- Description:	Extrae los marcos legales
    -- =================================================================
    SET NOCOUNT ON;
    SELECT IdMarcoLegal,
           MarcoLegal,
           activo,
           IsInterno,
           u.Nombre AS CreadoPor,
           CreadoEn
    FROM EN_MarcoLegal ml
	LEFT JOIN dbo.AP_Usuario u ON ml.CreadoPor=u.UsuarioID
	    ORDER BY IdMarcoLegal desc;
END;