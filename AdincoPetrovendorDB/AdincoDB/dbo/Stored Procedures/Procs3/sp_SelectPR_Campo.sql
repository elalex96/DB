-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20180824
-- Description:	Extrae campos de la tabla pr
-- =============================================
CREATE PROCEDURE sp_SelectPR_Campo
    -- Add the parameters for the stored procedure here
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

SELECT c.Nombre AS nombre, c.id FROM PR_Campo c
  JOIN dbo.PR_Bloque ON PR_Bloque.Id = C.Bloque
		WHERE dbo.PR_Bloque.idContrato=@IdContrato

END;