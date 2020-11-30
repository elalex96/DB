-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20190927
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_PR_ExtraeCiudades]--3,10061
    @idContrato INT,
    @idUsuario INT
AS
BEGIN
SELECT IdCiudadApiClima,c.Nombre+', '+e.Nombre AS Nombre FROM dbo.PR_Ciudad c
JOIN dbo.PR_Estado e ON c.Estado =e.Id
WHERE c.IdCiudadApiClima IS NOT NULL
END;