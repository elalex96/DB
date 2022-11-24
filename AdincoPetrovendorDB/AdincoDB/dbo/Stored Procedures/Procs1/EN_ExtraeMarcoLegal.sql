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
	-- Author:	Luis David
    -- Create date: 27/09/2019
    -- Description:	se agrega el bitjoa y nombreeningles para el issue 419
    -- =================================================================
	-- Author: Alexander Gomez
    -- Create date: 20/06/2022
    -- Description:	se agrega el campo de alias
    -- =================================================================
    SET NOCOUNT ON;
    SELECT IdMarcoLegal,
           MarcoLegal,
           activo,
           IsInterno,
           u.Nombre AS CreadoPor,
           CreadoEn,
		   ISNULL(MarcoLegalIngles,'') as MarcoLegalIngles,
		   BitJOA,
		   Alias
    FROM EN_MarcoLegal ml
	LEFT JOIN dbo.AP_Usuario u ON ml.CreadoPor=u.UsuarioID
	ORDER BY IdMarcoLegal desc;

END;
