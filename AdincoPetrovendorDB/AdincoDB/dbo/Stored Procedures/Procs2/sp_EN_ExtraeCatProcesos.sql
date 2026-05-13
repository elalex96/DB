-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20191029
-- Description:	extrae cat de procesos
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeCatProcesos]-- 3,10061
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
SELECT IdCatProceso,
       Clave,
       cp.Nombre,
       Descripcion,
       u.Nombre AS CreadoPor,
       CreadoEn
FROM EN_CatalogoProcesos cp
    JOIN dbo.AP_Usuario u
        ON cp.CreadoPor = u.UsuarioID;
END
