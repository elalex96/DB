
-- =============================================
-- Author:		DANIEL AC
-- Create date:19/04/2018
-- Description:	ALTA DE PROVEEDOR POR EL OPERADOR 
-- ============================================

CREATE PROCEDURE [dbo].[S_SP_RegistrarProveedor_Operador]
    @IdUsuario INT,
    @IdNacionalidad INT = 0,
    @RFC VARCHAR(30),
    @IdTipoRegimen INT,
    @RazonSocial NVARCHAR(MAX),
    @IdPais INT,
    @IdContrato INT = NULL,
    @IdProveedor INT = NULL
AS
BEGIN

    DECLARE @RFC_EXISTENTES INT = 0;

    SET @RFC_EXISTENTES  = (
                                      SELECT COUNT(IdProveedor) FROM dbo.S_Proveedor WHERE RFC = @RFC
                                  );

    IF ISNULL(@RFC_EXISTENTES, 0) = 0
    BEGIN
        /*REGISTRAR POR QUE NO SE ENCUENTRA NINGUN PROVEEDOR CON ESE RFC */

        IF @IdPais = 42 ---MEXICO 
            SET @IdNacionalidad = 1; -- NACIONAL
        ELSE
            SET @IdNacionalidad = 2; -- EXTRANJERO

        INSERT INTO dbo.S_Proveedor
        (
            IdNacionalidad,
            RFC,
            IdTipoRegimen,
            RazonSocial,
            IdPais,
            Activo,
            IdRegimenCapital
        )
        VALUES
        (   @IdNacionalidad, -- IdNacionalidad - int
            @RFC,            -- RFC - varchar(30)
            @IdTipoRegimen,  -- IdTipoRegimen - int
            @RazonSocial,    -- RazonSocial - nvarchar(max)
            @IdPais, 0, 5    -- Regimen Capital --> 5 NINGUNO
            );

        DECLARE @IdNuevoProveedor INT = @@IDENTITY;

        /*HISTORIAL DE ALTA DE PROVEEDORES POR EL OPERADOR*/

        INSERT INTO dbo.S_RegistroProveedorOperador
        (
            IdProveedorRegistrado,
            IdProveedorCreador,
            IdCreadoPor,
            CreadoEl,
            Activo
        )
        VALUES
        (   @IdNuevoProveedor, -- IdProveedorRegistrado - int
            @IdProveedor,      -- IdProveedorCreador - int
            @IdUsuario,        -- IdCreadoPor - int
            GETDATE(),         -- CreadoEl - datetime	    
            1                  -- Activo - bit  --> INACTIVO		 
            );

        SELECT 'PROVEEDOR_AGREGADO',
               @IdNuevoProveedor,
               @RFC,
               @RazonSocial;
    END;
    ELSE
    BEGIN
        DECLARE @PROVEEDOR NVARCHAR(MAX);

        SELECT @PROVEEDOR = (ISNULL(RazonSocial,'') + ' ' + ISNULL(RegimenCapital,''))
        FROM dbo.S_Proveedor
        WHERE RFC = @RFC;

        SELECT 'PROVEEDOR_EXISTENTE',
               @IdNuevoProveedor,
               @RFC,
               ISNULL(@PROVEEDOR, '');

    END;

END;