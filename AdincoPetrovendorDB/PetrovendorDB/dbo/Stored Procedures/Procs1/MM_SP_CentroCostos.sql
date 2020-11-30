-- =============================================
-- Author:      Daniel Cruz
-- Create date: 06-07-17
-- Description: 
-- =============================================
CREATE PROCEDURE [dbo].[MM_SP_CentroCostos]
-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdUsuario INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    -- Insert statements for procedure here Descripcion

	-- Si es de la operadora Ogarrio, DEA
	-- Entonces hay que aplicar el filtro
    IF EXISTS ( SELECT IdProveedor FROM dbo.DEA_Proveedor WHERE Activo = 1 AND IdProveedor = @IdProveedor)
    BEGIN
		SELECT CC.IdCentroCosto,
               CC.CentroCosto
        FROM dbo.CC_CentroCosto AS CC
            INNER JOIN dbo.CentroCostoFiltro filtro
                ON filtro.IdProveedor = CC.IdProveedor
                   AND filtro.Activo = 1
                   AND filtro.IdCentroCosto = CC.IdCentroCosto
        WHERE CC.IdProveedor = @IdProveedor
              AND CC.IsActivo = 1
			  AND filtro.IdUsuario = @IdUsuario
        ORDER BY CC.CentroCosto ASC
    END
    ELSE
    BEGIN    
		SELECT CC.IdCentroCosto,
               CC.CentroCosto
        FROM dbo.CC_CentroCosto AS CC
        WHERE CC.IdProveedor = @IdProveedor
              AND CC.IsActivo = 1
        ORDER BY CC.CentroCosto ASC
    END



END;
