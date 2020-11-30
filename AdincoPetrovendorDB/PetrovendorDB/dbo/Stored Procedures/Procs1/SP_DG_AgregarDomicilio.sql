-- =============================================
-- Author:		Daniel Cruz
-- Create date: 22/01/2018
-- Description:	Agregar Nuevo Domicilio
-- =============================================
CREATE PROCEDURE [dbo].[SP_DG_AgregarDomicilio]
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,
    @IdUsuario INT,
    @IdContrato INT,
    @FechaRegistro DATETIME,
    @IdTipoDomicilio INT,
    @Calle NVARCHAR(300),
    @NumeroExterior NVARCHAR(300),
    @NumeroInterior NVARCHAR(300),
    @Colonia NVARCHAR(300),
    @Municipio NVARCHAR(300),
    @Estado NVARCHAR(300),
    @IdPais INT,
    @CodigoPostal NVARCHAR(150),
    @TipoVialidad NVARCHAR(500),
    @NombreVialidad NVARCHAR(500)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    ---Validar si existe Domicilio Fiscal Activo

    DECLARE @ExisteDomicilioFiscal INT;


    IF (@IdTipoDomicilio = 1) -- SI EL DOMICILIO ES QUE SE QUIERE INGRESAR ES DOMICLIO FISCAL VALIDAR QUE NO EXISTA YA REGISTRADO UN DOMICILIO ACTIVO
    BEGIN

        SET @ExisteDomicilioFiscal =
        (
            SELECT COUNT(IdDomicilio)
            FROM dbo.DG_Domicilio
            WHERE IdProveedor = @IdProveedor
                  AND Activo = 1
                  AND IdTipoDomicilio = 1
        ); --> IdTipoDomicilio=1 Domiclio Fiscal

        IF @ExisteDomicilioFiscal = 0 --- SI NO EXISTE UN DOMILCIO REGISTRADO AGREGAR NUEVO DOMICILIO 
        BEGIN
            INSERT INTO dbo.DG_Domicilio
            (
                Estado,
                Municipio,
                Colonia,
                TipoViabilidad,
                NombreViabilidad,
                NoExterior,
                NoInterior,
                CodigoPostal,
                IdTipoDomicilio,
                IdProveedor,
                IdCreadoPor,
                FechaAlta,
                Activo,
                IdPais,
                Calle,
                Publico
            )
            VALUES
            (   @Estado,          -- Estado - nvarchar(300)
                @Municipio,       -- Municipio - nvarchar(300)
                @Colonia,         -- Colonia - nvarchar(300)
                @TipoVialidad,    -- TipoViabilidad - nvarchar(500)
                @NombreVialidad,  -- NombreViabilidad - nvarchar(500)
                @NumeroExterior,  -- NoExterior - nvarchar(300)
                @NumeroInterior,  -- NoInterior - nvarchar(300)
                @CodigoPostal,    -- CodigoPostal - nvarchar(150)
                @IdTipoDomicilio, -- IdTipoDomicilio - int
                @IdProveedor,     -- IdProveedor - int
                @IdUsuario,       -- IdCreadoPor - int
                GETDATE(),        -- FechaAlta - datetime
                1,                -- Activo - bit
                @IdPais,          -- IdPais - int	     
                @Calle,           -- Calle - nvarchar(300)
                1                 -- Publico - bit 
                );

            SELECT 'DOMICILIO_AGREGADO';
        END;
        ELSE
        BEGIN
            SELECT 'DOMICILIO_FISCAL_YA_DISPONIBLE';
        END;

    END;
    ELSE
    BEGIN
        INSERT INTO dbo.DG_Domicilio
        (
            Estado,
            Municipio,
            Colonia,
            TipoViabilidad,
            NombreViabilidad,
            NoExterior,
            NoInterior,
            CodigoPostal,
            IdTipoDomicilio,
            IdProveedor,
            IdCreadoPor,
            FechaAlta,
            Activo,
            IdPais,
            Calle,
            Publico
        )
        VALUES
        (   @Estado,          -- Estado - nvarchar(300)
            @Municipio,       -- Municipio - nvarchar(300)
            @Colonia,         -- Colonia - nvarchar(300)
            @TipoVialidad,    -- TipoViabilidad - nvarchar(500)
            @NombreVialidad,  -- NombreViabilidad - nvarchar(500)
            @NumeroExterior,  -- NoExterior - nvarchar(300)
            @NumeroInterior,  -- NoInterior - nvarchar(300)
            @CodigoPostal,    -- CodigoPostal - nvarchar(150)
            @IdTipoDomicilio, -- IdTipoDomicilio - int
            @IdProveedor,     -- IdProveedor - int
            @IdUsuario,       -- IdCreadoPor - int
            GETDATE(),        -- FechaAlta - datetime
            1,                -- Activo - bit
            @IdPais,          -- IdPais - int	     
            @Calle,           -- Calle - nvarchar(300)
            1                 -- Publico - bit 
            );
        SELECT 'DOMICILIO_AGREGADO';

    END;

END;
