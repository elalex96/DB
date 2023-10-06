IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_CatCFDIMetodoPago'
)
    DROP PROCEDURE SP_FI_CatCFDIMetodoPago
GO

CREATE PROCEDURE [dbo].[SP_FI_CatCFDIMetodoPago]
    @IdContrato INT = 0,
    @IdUsuario INT = 0
AS
BEGIN

	SELECT IdMetodoPago,c_MetodoPago AS MetodoPago
    FROM CatCFDI_c_MetodoPago (NOLOCK);

END