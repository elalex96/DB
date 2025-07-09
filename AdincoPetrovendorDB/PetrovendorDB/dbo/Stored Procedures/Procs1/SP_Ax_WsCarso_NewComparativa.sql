USE [Petrovendor]
GO
IF OBJECT_ID('Petrovendor..SP_Ax_WsCarso_NewComparativa') IS NOT NULL
BEGIN
DROP PROCEDURE SP_Ax_WsCarso_NewComparativa;
END
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: 15/10/2018
-- Description:	AGREGAR DETALLE DE UNA COMPARATIVA
-- =============================================
-- Author:		Luis David
-- Create date: 27/10/2021
-- Description:	Se corrige la ortografía 
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 28/11/2023
-- Description:	SE CORRIGE LA ORTOGRAFÍA 
-- =============================================
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 08/07/2025
-- Description:	Retorno de los usuarios que requieren notificaciones de las comprarativas
-- =============================================
CREATE PROCEDURE [dbo].[SP_Ax_WsCarso_NewComparativa]
    -- Add the parameters for the stored procedure here
    @LineaPresupuesto NVARCHAR(500),
    @Item NVARCHAR(MAX),
    @Cantidad FLOAT,
    @Unidad NVARCHAR(500),
    @LugarEntrega NVARCHAR(MAX),
    @Instalacion NVARCHAR(MAX),
    @FechaEntrega DATE,
    @TipoAdjudicacion INT,
    @JustificacionPedido NVARCHAR(MAX),
    @CentroCosto NVARCHAR(500),
    @Aprobadores NVARCHAR(MAX),
    @MensajeAprobacion NVARCHAR(MAX),
    @IdComparativa NVARCHAR(MAX),
    @IdPosicion NVARCHAR(MAX),
    @DataAreaID NVARCHAR(500),
    @FechaEntregaExist BIT = 0,
    @IdProveedor INT = -1,
    @IdUsuario INT = -1,
    @p1 VARCHAR(MAX),
    @p2 VARCHAR(MAX),
    @p3 VARCHAR(MAX),
    @p4 VARCHAR(MAX),
    @p5 VARCHAR(MAX),
    @p6 VARCHAR(MAX),
    @p7 VARCHAR(MAX),
    @p8 VARCHAR(MAX),
    @p9 VARCHAR(MAX),
    @p10 VARCHAR(MAX)
AS
BEGIN
    DECLARE @LPM INT
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    DECLARE @IdDinamicsAx INT,
            @IdInsertado INT,
            @ErrorRetorno NVARCHAR(MAX),
            @MensajeCorrecto NVARCHAR(MAX),
            @Stored NVARCHAR(500) = N'SP_Ax_WsCarso_NewComparativa'
			
    DECLARE @TablaComparativa TABLE
    (
        IdDinamicsAx INT,
            LineaPresupuesto NVARCHAR(MAX),
            Item NVARCHAR(MAX),
            Cantidad FLOAT,
            Unidad NVARCHAR(MAX),
            LugarEntrega NVARCHAR(MAX),
            Instalacion NVARCHAR(MAX),
            FechaEntrega DATE,
            TipoAdjudicacion INT,
            JustificacionPedido NVARCHAR(MAX),
            CentroCosto NVARCHAR(MAX),
            Aprobadores NVARCHAR(MAX),
            MensajeAprobacion NVARCHAR(MAX),
            Moneda NVARCHAR(MAX),
            IdComparativa NVARCHAR(MAX),
            IdPosicion NVARCHAR(MAX),
            DataAreaId NVARCHAR(MAX),
            FechaRegistro DATETIME,
            IdProveedor INT,
            IdUsuario INT,
            EditadoPor INT,
            EditadoEl DATETIME,
            Activo BIT,
            IdContrato INT,
            IdSolicitudPedido INT NULL,
            IdSolicitudPedidoDetalle INT NULL,
            IdMaterialSplit NVARCHAR(MAX),
            DescripcionMaterialSplit NVARCHAR(MAX),
            IdDomicilioPetrov INT,
            IdPresupuestoPetrov INT,
            IdPeriodoPetrov INT,
            IdUnidadPetrov INT,
            IdCentroCostoPetrov INT,
            IdMaterialPetrov INT,
            IdInstalacionPetrov INT,
            IdLineaPresupuestoPetrov INT,
            IdAreaContractual INT,
            IdUsuarioPetrov INT,
            ExisteSolpedDetalle INT,
            EliminadoError BIT,
            CharIndexUsuario INT,
            IdUsuarioAprobador INT,
            NombreUsuarioPetrov NVARCHAR(2000),
            NombreUsuarioAprobador NVARCHAR(2000)
    )

	DECLARE @TablaEnviarCorreo TABLE  
	(  
		Correo NVARCHAR(MAX),  
		Asunto NVARCHAR(MAX),  
		Html NVARCHAR(MAX)
	)  

	DECLARE @IdProveedorEmp INT,
        @IdUsuarioEmp INT,
        @IdContrato INT,
        @InsertaroActualizar NVARCHAR(400)

    INSERT INTO dbo.AX_ComparativaLog
    (
        FechaRegistro,
        LineaPresupuesto,
        Item,
        Cantidad,
        Unidad,
        LugarEntrega,
        Instalacion,
        FechaEntrega,
        TipoAdjudicacion,
        JustificacionPedido,
        CentroCosto,
        Aprobadores,
        MensajeAprobacion,
        IdComparativa,
        IdPosicion,
        DataAreaID,
        FechaEntregaExist,
        IdProveedor,
        IdUsuario,
        p1,
        p2,
        p3,
        p4,
        p5,
        p6,
        p7,
        p8,
        p9,
        p10
    )
    VALUES
    (GETDATE(), @LineaPresupuesto, @Item, @Cantidad, @Unidad, @LugarEntrega, @Instalacion, @FechaEntrega,
     @TipoAdjudicacion, @JustificacionPedido, @CentroCosto, @Aprobadores, @MensajeAprobacion, @IdComparativa,
     @IdPosicion, @DataAreaID, @FechaEntregaExist, @IdProveedor, @IdUsuario, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8,
     @p9, @p10)


    SELECT @IdProveedorEmp = IdProveedor,
           @IdUsuarioEmp = IdUsuario,
           @IdContrato = IdContrato
    FROM dbo.AX_ComparativaEmpresa
    WHERE DataAreaID = @DataAreaID;

    IF ISNULL(@IdProveedorEmp, 0) > 0
       AND ISNULL(@IdContrato, 0) > 0
       AND ISNULL(@IdUsuarioEmp, 0) > 0
    BEGIN

        --> VALIDAR FECHA 
        IF @FechaEntregaExist = 0
            SET @FechaEntrega = NULL;

        SELECT @IdDinamicsAx = IdDinamicsAx
        FROM dbo.AX_Comparativa
        WHERE IdComparativa = @IdComparativa
              AND IdPosicion = @IdPosicion
              AND DataAreaId = @DataAreaID

        -->VALIDAR SI YA EXISTE LA COMPARATIVA
        DECLARE @EXISTE_COMPARATIVA INT =
                (
                    SELECT COUNT(IdDinamicsAx)
                    FROM dbo.AX_Comparativa
                    WHERE IdComparativa = @IdComparativa
                          AND IdPosicion = @IdPosicion
                          AND DataAreaId = @DataAreaID
                );

        EXEC @LPM = dbo.FN_CarsoObtenerLineaPresupuesto @LineaPresupuesto,
                                                        @p1,
                                                        @IdContrato

        IF ISNULL(@LPM, 0) > 0
        BEGIN

            IF @EXISTE_COMPARATIVA > 0
            BEGIN
                ---> EXISTE ACTUALIZAR 
                UPDATE dbo.AX_Comparativa
                SET LineaPresupuesto = @LineaPresupuesto,       -- LineaPresupuesto - nvarchar(500)
                    Item = @Item,                               -- Item - nvarchar(500)
                    Cantidad = @Cantidad,                       -- Cantidad - float
                    Unidad = @Unidad,                           -- Unidad - nvarchar(500)
                    LugarEntrega = @LugarEntrega,               -- LugarEntrega - nvarchar(500)
                    Instalacion = @Instalacion,                 -- Instalacion - nvarchar(500)
                    FechaEntrega = @FechaEntrega,               -- FechaEntrega - date
                    TipoAdjudicacion = @TipoAdjudicacion,       -- TipoAdjudicacion - int
                    JustificacionPedido = @JustificacionPedido, -- JustificacionPedido - nvarchar(max)
                    CentroCosto = @CentroCosto,                 -- CentroCosto - nvarchar(500)
                    Aprobadores = @Aprobadores,                 -- Aprobadores - nvarchar(max)
                    MensajeAprobacion = @MensajeAprobacion,     -- MensajeAprobacion - nvarchar(max)
                                                                -- Moneda - int
                    IdComparativa = @IdComparativa,             -- IdComparativa - nvarchar(500)
                    IdPosicion = @IdPosicion,                   -- IdPosicion - int
                    DataAreaId = @DataAreaID,                   -- DataAreaId - char(4)
                    EditadoPor = @IdUsuarioEmp,
                    EditadoEl = GETDATE(),
                    IdProveedor = @IdProveedorEmp,              -- IdProveedor - int
                    IdUsuario = @IdUsuarioEmp,                  -- IdUsuario - int	
                    Activo = 1,                                 -- Activo - bit
                    IdContrato = @IdContrato,
                    pool1 = @p1,
                    pool2 = @p2,
                    pool3 = @p3,
                    pool4 = @p4,
                    pool5 = @p5,
                    pool6 = @p6,
                    pool7 = @p7,
                    pool8 = @p8,
                    pool9 = @p9,
                    pool10 = @p10,
                    Editado = 1,
                    IdLineaPresupuesto = @LPM
                WHERE IdComparativa = @IdComparativa
                      AND IdPosicion = @IdPosicion
             AND DataAreaId = @DataAreaID;

                SELECT @InsertaroActualizar = N'Actualizar'

            END;
            ELSE
            BEGIN

                ---> NO EXISTE AGREGAR
                INSERT INTO dbo.AX_Comparativa
                (
                    LineaPresupuesto,
                    Item,
                    Cantidad,
                    Unidad,
                    LugarEntrega,
                    Instalacion,
                    FechaEntrega,
                    TipoAdjudicacion,
                    JustificacionPedido,
                    CentroCosto,
                    Aprobadores,
                    MensajeAprobacion,
                    IdComparativa,
                    IdPosicion,
                    DataAreaId,
                    FechaRegistro,
                    IdProveedor,
                    IdUsuario,
                    Activo,
                    IdContrato,
                    pool1,
                    pool2,
                    pool3,
                    pool4,
                    pool5,
                    pool6,
                    pool7,
                    pool8,
                    pool9,
                    pool10,
                    Editado,
                    IdLineaPresupuesto
                )
                VALUES
                (   @LineaPresupuesto,    -- LineaPresupuesto - nvarchar(500)
                    @Item,                -- Item - nvarchar(500)
                    @Cantidad,            -- Cantidad - float
                    @Unidad,              -- Unidad - nvarchar(500)
                    @LugarEntrega,        -- LugarEntrega - nvarchar(500)
                    @Instalacion,         -- Instalacion - nvarchar(500)
                    @FechaEntrega,        -- FechaEntrega - date
                    @TipoAdjudicacion,    -- TipoAdjudicacion - int
                    @JustificacionPedido, -- JustificacionPedido - nvarchar(max)
                    @CentroCosto,         -- CentroCosto - nvarchar(500)
                    @Aprobadores,         -- Aprobadores - nvarchar(max)
                    @MensajeAprobacion,   -- MensajeAprobacion - nvarchar(max)
                    @IdComparativa,       -- IdComparativa - nvarchar(500)
                    @IdPosicion,          -- IdPosicion - int
                    @DataAreaID,          -- DataAreaId - char(4)
                    GETDATE(),            -- FechaRegistro - int
                    @IdProveedorEmp,      -- IdProveedor - int
                    @IdUsuarioEmp,        -- IdUsuario - int	   
                    1,                    -- Activo - bit
                    @IdContrato,          --IdContrato int 
                    @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, 0, @LPM);


                SELECT @IdInsertado = SCOPE_IDENTITY()
                SELECT @InsertaroActualizar = N'Insertar'
            END;
        END
        ELSE
        BEGIN
            SELECT @ErrorRetorno
                = CONCAT(
                            'La línea de presupuesto enviada no existe: ',
                            LTRIM(ISNULL(@LineaPresupuesto, ' nulo ')),
                            ' - Mes: ',
                            LTRIM(ISNULL(@p1, ' nulo '))
                        )

            INSERT INTO dbo.Ax_BitacoraCarso
            (
                ErrorMotivo,
                Lugar,
                Comparativa,
                DataAreaId,
                RecId,
                Accion,
				FechaRegistro
            )
            SELECT @ErrorRetorno,
                   @Stored,
                   @IdComparativa,
                   @DataAreaID,
                   @IdPosicion,
                   @InsertaroActualizar,
				   GETDATE()

            SELECT CONCAT('Error: ',
                   @ErrorRetorno), ''

        END;
    END;
    ELSE
    BEGIN
        SELECT @ErrorRetorno = CONCAT('DataAreaID No registrado en el sistema: ', LTRIM(ISNULL(@DataAreaID, ' nulo ')))

        INSERT INTO dbo.Ax_BitacoraCarso
        (
            ErrorMotivo,
            Lugar,
            Comparativa,
            DataAreaId,
            RecId,
            Accion,
			FechaRegistro
        )
        SELECT @ErrorRetorno,
               @Stored,
               @IdComparativa,
               @DataAreaID,
               @IdPosicion,
               @InsertaroActualizar,
			   GETDATE()

        SELECT CONCAT('Error: ',
               @ErrorRetorno), ''
    END;

    -- Despues del todo
    INSERT INTO @TablaComparativa
    (
        IdDinamicsAx,
           LineaPresupuesto,
           Item,
           Cantidad,
           Unidad,
           LugarEntrega,
           Instalacion,
           FechaEntrega,
           TipoAdjudicacion,
           JustificacionPedido,
           CentroCosto,
           Aprobadores,
           MensajeAprobacion,
           Moneda,
           IdComparativa,
           IdPosicion,
           DataAreaId,
           FechaRegistro,
           IdProveedor,
           IdUsuario,
           EditadoPor,
           EditadoEl,
           Activo,
           IdContrato,
           IdSolicitudPedido,
           IdSolicitudPedidoDetalle,
           IdMaterialSplit,
           DescripcionMaterialSplit,
           IdDomicilioPetrov,
           IdPresupuestoPetrov,
           IdPeriodoPetrov,
           IdUnidadPetrov,
           IdCentroCostoPetrov,
           IdMaterialPetrov,
           IdInstalacionPetrov,
           IdLineaPresupuestoPetrov,
           IdAreaContractual,
           IdUsuarioPetrov,
           ExisteSolpedDetalle,
           EliminadoError,
           CharIndexUsuario,
           IdUsuarioAprobador,
           NombreUsuarioPetrov,
           NombreUsuarioAprobador
    )
    EXECUTE Petrovendor.dbo.SP_GenerarSolpedCarso

	INSERT INTO @TablaEnviarCorreo(
		Correo,  
		Asunto,  
		Html
	)
	SELECT 
		NombreUsuarioAprobador,
		DescripcionMaterialSplit,
		MensajeAprobacion
	FROM @TablaComparativa
	WHERE IdDinamicsAx = 0
	AND Item = 'CORREO'

	DELETE FROM @TablaComparativa WHERE IdComparativa = 0 AND Item = 'CORREO'

    DECLARE 
            @MotivoError NVARCHAR(MAX),
            @IdBitacora INT

    -- Ya que se genero o actualizo la comparativa
    IF (@InsertaroActualizar = 'Actualizar')
    BEGIN
        SELECT @IdInsertado = IdDinamicsAx
        FROM dbo.AX_Comparativa
        WHERE DataAreaId = @DataAreaID
              AND IdPosicion = @IdPosicion
              AND IdComparativa = @IdComparativa

        INSERT INTO dbo.Ax_BitacoraCarso
        (
            ErrorMotivo,
            Lugar,
            Comparativa,
            DataAreaId,
            RecId,
            Accion,
			FechaRegistro
        )
        SELECT i.Motivo,
               'SP_GenerarSolpedCarso',
               @IdComparativa,
               @DataAreaID,
               @IdPosicion,
               @InsertaroActualizar,
			   GETDATE()
        FROM @TablaComparativa comp
            INNER JOIN dbo.Ax_Incorrectos i
                ON comp.IdDinamicsAx = i.IdDocumento
                   AND LTRIM(RTRIM(i.Motivo)) <> ''
        WHERE comp.IdDinamicsAx = @IdInsertado

        SELECT @IdBitacora = SCOPE_IDENTITY()

        SELECT @MotivoError = ErrorMotivo
        FROM dbo.Ax_BitacoraCarso
        WHERE Id = @IdBitacora

        IF EXISTS
        (
            SELECT 1
            FROM @TablaComparativa comp
                INNER JOIN dbo.Ax_Incorrectos i
                    ON comp.IdDinamicsAx = i.IdDocumento 
                       AND LTRIM(RTRIM(i.Motivo)) <> ''
            WHERE comp.IdDinamicsAx = @IdInsertado
        )
        BEGIN
            SELECT 
                   CONCAT(
                             'Falló Actualización comparativa:',
                             @IdComparativa,
                             ' RecId: ',
                             @IdPosicion,
                             ' DataAreaId: ',
                             @DataAreaID,
                             ' Motivo: ',
                             @MotivoError
                         ), ''
        END
        ELSE
        BEGIN
            SELECT CONCAT('Actualización exitosa ', @IdComparativa),
                   'UPDATE',
				   'Actualizacion'           			
        END
    END

    IF (@InsertaroActualizar = 'Insertar')
    BEGIN
        INSERT INTO dbo.Ax_BitacoraCarso
        (
            ErrorMotivo,
            Lugar,
            Comparativa,
            DataAreaId,
            RecId,
            Accion,
			FechaRegistro
        )
        SELECT i.Motivo,
               'SP_GenerarSolpedCarso',
               @IdComparativa,
               @DataAreaID,
               @IdPosicion,
               @InsertaroActualizar,
			   GETDATE()
        FROM @TablaComparativa comp
            INNER JOIN dbo.Ax_Incorrectos i
                ON comp.IdDinamicsAx = i.IdDocumento
                   AND LTRIM(RTRIM(i.Motivo)) <> ''
        WHERE comp.IdDinamicsAx = @IdInsertado

        SELECT @IdBitacora = SCOPE_IDENTITY()

        SELECT @MotivoError = ErrorMotivo
        FROM dbo.Ax_BitacoraCarso
        WHERE Id = @IdBitacora

        IF EXISTS
        (
            SELECT 1
            FROM @TablaComparativa comp
                INNER JOIN dbo.Ax_Incorrectos i
                    ON comp.IdDinamicsAx = i.IdDocumento
                       AND LTRIM(RTRIM(i.Motivo)) <> ''
            WHERE comp.IdDinamicsAx = @IdInsertado
        )
        BEGIN
            SELECT 
                   CONCAT(
                             'Falló Inserción de comparativa:',
                             @IdComparativa,
                             ' RecId: ',
                             @IdPosicion,
                             ' DataAreaId: ',
                             @DataAreaID,
                             ' Motivo: ',
                             @MotivoError
                         ), ''
        END
        ELSE
        BEGIN
            SELECT CONCAT('Registro exitoso ', @IdComparativa),
                   @IdInsertado,
                   'INSERT '
        END

    END

	SELECT * FROM @TablaEnviarCorreo

END;
