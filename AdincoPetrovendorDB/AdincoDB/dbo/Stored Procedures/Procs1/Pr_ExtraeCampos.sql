-- =============================================
-- Author:		Reyna Itzel
-- Create date: 20180825
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE Pr_ExtraeCampos
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;


 SELECT C.Id AS id, 
           C.Clave AS clave,
           C.Nombre AS nombre,
           C.Descripcion AS descripcion,
           C.Estatus AS estatus,
           PR_Bloque.Id AS bloque
		
    FROM dbo.PR_Campo C
        JOIN dbo.PR_Bloque ON PR_Bloque.Id = C.bloque
		WHERE dbo.PR_Bloque.idContrato=@IdContrato

END;