-- =============================================
-- Author:		Reyna Itzel
-- Create date: 20180825
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE Pr_ExtraeBloques
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT C.Id AS bloque, 
           C.Clave AS clave,
           C.Nombre AS nombre,
           C.Descripcion AS descripcion,
           C.Estatus AS estatus
    FROM dbo.PR_Bloque c
	WHERE IdContrato=@IdContrato

END;