USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'MM_SP_CentroCostos'
)
    DROP PROCEDURE MM_SP_CentroCostos;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Daniel Cruz
-- Create date: 06-07-17
-- Description: 
-- =============================================
-- =============================================
-- Author:      Alexander Gomez
-- Create date: 25/11/2021
-- Description: optimizacion
-- =============================================
-- =============================================
-- Author:      Alexander Gomez
-- Create date: 13/07/20223
-- Description: se descarta amatitlan
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
    IF EXISTS ( SELECT IdProveedor FROM dbo.DEA_Proveedor (NOLOCK) WHERE Activo = 1 AND IdProveedor = @IdProveedor AND RFC <> 'PAM140722DK6')
    BEGIN
		SELECT CC.IdCentroCosto,
               CC.CentroCosto
        FROM dbo.CentroCostoFiltro AS filtro (NOLOCK)
            JOIN dbo.CC_CentroCosto CC (NOLOCK)
                ON CC.IdProveedor = @IdProveedor
				   AND filtro.IdUsuario = @IdUsuario
				   AND filtro.IdProveedor = CC.IdProveedor
				   AND filtro.IdCentroCosto = CC.IdCentroCosto
                   AND filtro.Activo = 1
				   AND CC.IsActivo = 1
        ORDER BY CC.CentroCosto ASC
    END
    ELSE
    BEGIN    
		SELECT CC.IdCentroCosto,
               CC.CentroCosto
        FROM dbo.CC_CentroCosto AS CC (NOLOCK)
        WHERE CC.IdProveedor = @IdProveedor
              AND CC.IsActivo = 1
        ORDER BY CC.CentroCosto ASC
    END



END;