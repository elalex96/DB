USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_CO_ActualizarDetallePeticionMaterial_MV1_5'
)
    DROP PROCEDURE SP_CO_ActualizarDetallePeticionMaterial_MV1_5;
GO
/****** Object:  StoredProcedure [dbo].[SP_CO_ActualizarDetallePeticionMaterial_MV1_5]    Script Date: 27/05/2022 01:09:49 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:           Daniel AC
-- Create date: 13-08-2019
-- Description: Agregue validación que si es un Proveedor de CARSO no agregar Marca, Modelo, No Parte a Descripción material  cotizado
-- =============================================
-- =============================================
-- Author:           Daniel AC
-- Create date: 27-05-2022
-- Description: Agregue calculo del subtotal cuando se actualiza un material y tambien se cambio el concatenado de los cambios realizados en la edición de la cotización del material 
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ActualizarDetallePeticionMaterial_MV1_5]
    -- Add the parameters for the stored procedure here
    @IdPeticionOfertaDetalle INT, 
	@PrecioUnitario FLOAT, 
	@Disponibilidad FLOAT, 
	@IdMoneda INT ,
    @ComentarioSubcontratista NVARCHAR (MAX), 
    @IdMaterialVendedor INT, 
    @IdPeticionOferta INT, 
    @FechaVigencia DATETIME ,
    @IdProveedorActual INT, 
    @NoCotizar BIT,
    @IdEdicionCotizacion INT,
    @IdEstatusEdicionCotizacion INT ,
    @IdUnidadVendedor INT,
    @FechaEntrega DATETIME ,
    @IdContrato INT, 
    @IdUsuario INT, 
    @FechaRegistro DATETIME,
    @IdCondicionPago INT=NULL,
    @DiasCredito INT=NULL
AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON ;

        --SET @IdMaterialVendedor = null;

		--SI TIENE @IdEdicionCotizacion ES PORQUE FUE EDITADO
		IF @IdEdicionCotizacion <> 0
		BEGIN
			SET @IdEstatusEdicionCotizacion = 1;
		END

        --VALIDACIÓN CARSO ---      
        DECLARE @EsProveedorDeCARSO INT 
        CREATE TABLE #ProveedoresCARSO(IdProveedor INT)
        
		INSERT INTO #ProveedoresCARSO(IdProveedor)VALUES(650) ---VALOR A EDITAR SEGÚN EL PROVEEDOR CARSO ##EDITAR##

        SELECT @EsProveedorDeCARSO= COUNT(IdProveedor)
        FROM #ProveedoresCARSO 
        WHERE IdProveedor IN (
                SELECT  SP.IdProveedor
                FROM dbo.MM_PeticionOferta PO
                INNER JOIN dbo.MM_SolicitudPedido SP ON SP.IdSolicitudPedido=PO.IdSolicitudPedido 
                WHERE IdPeticionOferta=@IdPeticionOferta)

        --FIN VALIDACIÓN CARSO --
        DECLARE @PrecioUnitario_Actual FLOAT, @Disponibilidad_Actual FLOAT, @IdMoneda_Actual INT ,
                @MONEDA_ACTUAL NVARCHAR (300), @MONEDA NVARCHAR (300) ,
                @ComentarioSubcontratista_Actual NVARCHAR (MAX) ,
                ----------------------
                @IdMaterialVendedor_Actual INT, @FechaVigencia_Actual DATETIME, @NoCotizar_Actual BIT ,
                @Detalle NVARCHAR (MAX)  =   '', @Subtotal FLOAT, @DisponibilidadNEW DECIMAL (20, 3), @MaterialCotizadoTextC NVARCHAR (MAX) ,
                @MaterialCotizadoTextL NVARCHAR (MAX), @UnidadCotizada NVARCHAR (MAX), @FechaEntrega_Actual DATETIME,
                @IdCondicionDePago_Actual INT, @DiasCredito_Actual INT 

        SET @DisponibilidadNEW = CAST(@Disponibilidad AS DECIMAL (20, 3))

        --IF ISNULL(@IdMaterialVendedor,0) <> 0
        --BEGIN
        --#EDICION COTIZAR SIN EDICION EN HISTORIAL
        IF @NoCotizar = 0
           AND  @IdEdicionCotizacion = 0
           AND  @IdEstatusEdicionCotizacion = 0
            BEGIN
                SET @Subtotal = @PrecioUnitario * @DisponibilidadNEW ;
                ---VALIDACIÓN CARSO
                IF @EsProveedorDeCARSO > 0
                BEGIN 
                --ES PROVEEDOR CARSO
                SET @MaterialCotizadoTextC = (   SELECT 
                                                 DescripcionCorta                                               
                                                 FROM dbo.MM_Material
                                                 WHERE IdMaterial = @IdMaterialVendedor )
                END 
                ELSE 
                BEGIN 
                -- NO ES PROVEEDOR CARSO
                SET @MaterialCotizadoTextC = (   SELECT 
                                                 CONCAT (DescripcionCorta,
                                                 ' Marca: ', CASE WHEN ISNULL(LEN(Marca),0)>0 THEN Marca ELSE ' S/M' END,
                                                 ' Modelo: ', CASE WHEN ISNULL(LEN(Modelo),0)>0 THEN Modelo ELSE ' S/M' END,
                                                 ' No. Parte: ',CASE WHEN ISNULL(LEN(NumeroParte),0)>0 THEN NumeroParte  ELSE ' S/NP' END)
                                                 --DescripcionCorta
                                                   FROM dbo.MM_Material
                                                  WHERE IdMaterial = @IdMaterialVendedor )
                END 
                SET @MaterialCotizadoTextL = (   SELECT DescripcionLarga
                                                   FROM dbo.MM_Material
                                                  WHERE IdMaterial = @IdMaterialVendedor )

                SET @UnidadCotizada = (   SELECT    Unidad
                                            FROM    dbo.PV_MM_MaterialUnidad
                                           WHERE    IdUnidad = @IdUnidadVendedor )

                UPDATE  [dbo].[MM_PeticionOfertaDetalle]
                   SET  [PrecioUnitario] = CAST(@PrecioUnitario AS NUMERIC (18, 2)) ,
                        [ComentarioSubcontratista] = @ComentarioSubcontratista, 
						[ModificadoPor] = @IdUsuario ,
                        [ModificadoEl] = GETDATE (), 
						[IdMoneda] = @IdMoneda, 
						[Disponibilidad] = @DisponibilidadNEW ,
                        [Cotizado] = 1, 
						[SubTotal] = @Subtotal, 
						[FechaVigencia] = @FechaVigencia ,
                        [ModificadoProveedorPor] = @IdProveedorActual, 
						[IdMaterialVendedor] = @IdMaterialVendedor ,
                        [NoCotizar] = @NoCotizar, 
						[IdUnidadProveedor] = @IdUnidadVendedor ,
                        [UnidadProveedor] = @UnidadCotizada, 
						[MaterialCotizadoTextoC] = @MaterialCotizadoTextC ,
                        [MaterialCotizadoTextoL] = @MaterialCotizadoTextL, 
						FechaEntrega = @FechaEntrega,
                        [IdCondicionPago]=@IdCondicionPago,
						DiasCredito= @DiasCredito
                 WHERE  [IdPeticionOfertaDetalle] = @IdPeticionOfertaDetalle ;
            END ;
        --#EDICION NO COTIZAR SIN EDICION EN HISTORIAL
        IF @NoCotizar = 1
           AND  @IdEdicionCotizacion = 0
           AND  @IdEstatusEdicionCotizacion = 0
            BEGIN
                UPDATE  [dbo].[MM_PeticionOfertaDetalle]
                   SET  [NoCotizar] = @NoCotizar, 
						[PrecioUnitario] = NULL, 
						[ComentarioSubcontratista] = NULL ,
                        [ModificadoPor] = @IdUsuario, 
						[ModificadoEl] = GETDATE (), 
						[IdMoneda] = NULL ,
                        [Disponibilidad] = NULL, 
						[Cotizado] = 0, 
						[SubTotal] = NULL, 
						[FechaVigencia] = NULL ,
                        [ModificadoProveedorPor] = @IdProveedorActual, 
						[IdMaterialVendedor] = NULL ,
                        [IdUnidadProveedor] = NULL, 
						[UnidadProveedor] = NULL, 
						[MaterialCotizadoTextoC] = NULL ,
                        [MaterialCotizadoTextoL] = NULL, 
						FechaEntrega = NULL,
                        [IdCondicionPago]=NULL,
						DiasCredito= NULL
                 WHERE  [IdPeticionOfertaDetalle] = @IdPeticionOfertaDetalle ;
            END ;

        --#EDICION COTIZAR CON EDICION
        IF @NoCotizar = 0
           AND  @IdEdicionCotizacion <> 0
           AND  @IdEstatusEdicionCotizacion = 1
            BEGIN

                SET @NoCotizar_Actual = (   SELECT  NoCotizar
                                              FROM  dbo.MM_PeticionOfertaDetalle
                                             WHERE  IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle ) ;
            -----------------------------------------------------------------------------------------------------
                IF @EsProveedorDeCARSO > 0
                BEGIN 
                --ES PROVEEDOR CARSO
                SET @MaterialCotizadoTextC = (   SELECT 
                                                 DescripcionCorta                                               
                                                 FROM dbo.MM_Material
                                                 WHERE IdMaterial = @IdMaterialVendedor )
                END 
                ELSE 
                BEGIN 
                -- NO ES PROVEEDOR CARSO
                        SET @MaterialCotizadoTextC = (   SELECT CONCAT (ISNULL(DescripcionCorta,''),
                                                            ' Marca: ', CASE WHEN ISNULL(LEN(Marca),0)>0 THEN Marca ELSE ' S/M' END,
                                                            ' Modelo: ', CASE WHEN ISNULL(LEN(Modelo),0)>0 THEN Modelo ELSE ' S/M' END,
                                                            ' No. Parte: ',CASE WHEN ISNULL(LEN(NumeroParte),0)>0 THEN NumeroParte  ELSE ' S/NP' END )                                                            
                                                           FROM dbo.MM_Material
                                                          WHERE IdMaterial = @IdMaterialVendedor )
                END 

                SET @MaterialCotizadoTextL = (   SELECT DescripcionLarga
                                                    FROM dbo.MM_Material
                                                    WHERE IdMaterial = @IdMaterialVendedor )
                SET @UnidadCotizada = (   SELECT    Unidad
                                            FROM    dbo.PV_MM_MaterialUnidad
                                            WHERE    IdUnidad = @IdUnidadVendedor )

         -----------------------------------------------------------------------------------------------------
                IF ISNULL ( @NoCotizar_Actual, 0 ) <> @NoCotizar
                    BEGIN

                        SET @Detalle
                            = CONCAT( ISNULL(@Detalle,'')
                                , ' *Se cambio de no cotizar a  cotizar servicio/material, con los siguientes datos: ' ) ;

                        SET @Detalle
                            = CONCAT( @Detalle , ' *Material a cotizar: '
                                , CAST(ISNULL ( @IdMaterialVendedor, 0 ) AS NVARCHAR (MAX)) , ' - '
                                , (SELECT    CONCAT (DescripcionCorta,
                                                 ' Marca: ', CASE WHEN ISNULL(LEN(Marca),0)>0 THEN Marca ELSE ' S/M' END,
                                                 ' Modelo: ', CASE WHEN ISNULL(LEN(Modelo),0)>0 THEN Modelo ELSE ' S/M' END,
                                                 ' No. Parte: ',CASE WHEN ISNULL(LEN(NumeroParte),0)>0 THEN NumeroParte  ELSE ' S/NP' END )                                                
                                        FROM    dbo.MM_Material
                                       WHERE    IdMaterial = @IdMaterialVendedor))
                        SET @Detalle
                            = CONCAT( @Detalle , ' *Precio unitario: '
                                , CAST(ISNULL ( @PrecioUnitario, 0 ) AS NVARCHAR (MAX))) ;

                        SET @Detalle
                            = CONCAT( @Detalle , ' *Disponibilidad a cotizar de: '
                                , CAST(ISNULL ( @DisponibilidadNEW, 0 ) AS NVARCHAR (MAX))) ;

                        SET @MONEDA = ( SELECT TipoMonedaCorto FROM  dbo.PV_TipoMoneda WHERE IdMoneda = @IdMoneda ) ;
                        SET @Detalle = CONCAT( @Detalle , ' *Moneda: ' , ISNULL ( @MONEDA, '' )) ;
                        SET @Detalle = CONCAT( @Detalle , ' *Comentario: ' , ISNULL ( @ComentarioSubcontratista, '' )) ;
                        SET @Detalle
                            = CONCAT( @Detalle , ' *Fecha vigencia cotización de: '
                                , CAST(ISNULL ( @FechaVigencia, '' ) AS NVARCHAR (MAX))) ;

                        SET @Detalle
                            = CONCAT( @Detalle , ' *Fecha entrega de cotización: '
                                , CAST(ISNULL ( @FechaEntrega, '' ) AS NVARCHAR (MAX)))

                        DECLARE @CondicionPago NVARCHAR(MAX)
                        SELECT @CondicionPago=CondicionPago FROM dbo.MM_CondicionPago WHERE IdCondicionPago=@IdCondicionPago
                        -- IF @IdCondicionPago = 1 es de crédito

                        SET @Detalle =
                        CONCAT(@Detalle ,' *Condición de pago: '
                            ,@CondicionPago , CASE WHEN @IdCondicionPago=1 THEN CONCAT(CAST(@DiasCredito AS nvarchar(MAX)), ' día(s) de crédito') ELSE '' END)

						SET @Subtotal = @PrecioUnitario * @DisponibilidadNEW;

                        UPDATE  [dbo].[MM_PeticionOfertaDetalle]
                           SET  [PrecioUnitario] = CAST(@PrecioUnitario AS NUMERIC (18, 2)) ,
                                [ComentarioSubcontratista] = @ComentarioSubcontratista, 
                                [ModificadoPor] = @IdUsuario ,
                                [ModificadoEl] = GETDATE (), 
                                [IdMoneda] = @IdMoneda ,
                                [Disponibilidad] = @DisponibilidadNEW, 
                                [Cotizado] = 1, 
                                [SubTotal] = @Subtotal ,
                                [FechaVigencia] = @FechaVigencia, 
                                [ModificadoProveedorPor] = @IdProveedorActual ,
                                [IdMaterialVendedor] = @IdMaterialVendedor, 
                                [NoCotizar] = @NoCotizar ,
                                [IdUnidadProveedor] = @IdUnidadVendedor, 
                                [UnidadProveedor] = @UnidadCotizada ,
                                [MaterialCotizadoTextoC] = @MaterialCotizadoTextC ,
                                [MaterialCotizadoTextoL] = @MaterialCotizadoTextL, 
                                FechaEntrega = @FechaEntrega,
                                [IdCondicionPago]=@IdCondicionPago,
                                DiasCredito= @DiasCredito
                         WHERE  [IdPeticionOfertaDetalle] = @IdPeticionOfertaDetalle

                        INSERT INTO MM_HistorialEdicionCotizacion
                            ( [IdEdicionCotizacion], [IdUsuario], [IdProveedor], [Fecha], [IdPeticionOfertaDetalle] ,
                              [Descripcion] )
                        VALUES
                            ( @IdEdicionCotizacion, @IdUsuario, @IdProveedorActual, GETDATE () ,
                              @IdPeticionOfertaDetalle , ISNULL ( @Detalle, 'Sin cambios.' )) ;

                    END
                ELSE
                    BEGIN

                        --Asignacion de los valores actuales de la peticion oferta para revisar si hubo cambios
                        SELECT  @IdMaterialVendedor_Actual = IdMaterialVendedor ,
                                @PrecioUnitario_Actual = PrecioUnitario, 
								@Disponibilidad_Actual = Disponibilidad ,
                                @IdMoneda_Actual = IdMoneda ,
                                @ComentarioSubcontratista_Actual = ComentarioSubcontratista ,
                                @FechaVigencia_Actual = FechaVigencia,
								@FechaEntrega_Actual = FechaEntrega,
                                @IdCondicionDePago_Actual=IdCondicionPago, 
								@DiasCredito_Actual=DiasCredito
                          FROM  dbo.MM_PeticionOfertaDetalle
                         WHERE  IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle

                        IF ISNULL ( @IdMaterialVendedor_Actual, 0 ) <> @IdMaterialVendedor
                            BEGIN
                                SET @Detalle
                                    = CONCAT( @Detalle , ' *Cambio material a cotizar de: '
                                        , CAST(ISNULL ( @IdMaterialVendedor_Actual, 0 ) AS NVARCHAR (MAX)) + ' - '
                                        ,   (SELECT CONCAT (DescripcionCorta,
                                                 ' Marca: ', CASE WHEN ISNULL(LEN(Marca),0)>0 THEN Marca ELSE ' S/M' END,
                                                 ' Modelo: ', CASE WHEN ISNULL(LEN(Modelo),0)>0 THEN Modelo ELSE ' S/M' END,
                                                 ' No. Parte: ',CASE WHEN ISNULL(LEN(NumeroParte),0)>0 THEN NumeroParte  ELSE ' S/NP' END )                                                
                                                FROM    dbo.MM_Material
                                               WHERE    IdMaterial = 0 ) ,' a: '
                                        , CAST(ISNULL ( @IdMaterialVendedor, 0 ) AS NVARCHAR (MAX)) + ' - '
                                        , (   SELECT    CONCAT (DescripcionCorta,
                                                 ' Marca: ', CASE WHEN ISNULL(LEN(Marca),0)>0 THEN Marca ELSE ' S/M' END,
                                                 ' Modelo: ', CASE WHEN ISNULL(LEN(Modelo),0)>0 THEN Modelo ELSE ' S/M' END,
                                                 ' No. Parte: ',CASE WHEN ISNULL(LEN(NumeroParte),0)>0 THEN NumeroParte  ELSE ' S/NP' END )                                                
                                                FROM    dbo.MM_Material
                                               WHERE    IdMaterial = @IdMaterialVendedor )) ;
                            END ;

                        IF ISNULL ( @PrecioUnitario_Actual, 0 ) <> @PrecioUnitario
                            BEGIN
                                SET @Detalle
                                    = CONCAT( @Detalle , ' *Cambio precio unitario de: '
                                        , CAST(ISNULL ( @PrecioUnitario_Actual, 0 ) AS NVARCHAR (MAX)) , ' a: '
                                        , CAST(ISNULL ( @PrecioUnitario, 0 ) AS NVARCHAR (MAX)) , ' ' ) ;
                            END ;
                        IF ISNULL ( @Disponibilidad_Actual, 0 ) <> @DisponibilidadNEW
                            BEGIN
                                SET @Detalle
                                    = CONCAT( @Detalle , ' *Cambio cantidad de: '
                                        , CAST(ISNULL ( @Disponibilidad_Actual, 0 ) AS NVARCHAR (MAX)) , ' a: '
                                        , CAST(ISNULL ( @DisponibilidadNEW, 0 ) AS NVARCHAR (MAX)) , ' ' ) ;
                            END ;

                        IF ISNULL ( @IdMoneda_Actual, 0 ) <> @IdMoneda
                            BEGIN
                                SET @MONEDA_ACTUAL = (   SELECT TipoMonedaCorto
                                                           FROM dbo.PV_TipoMoneda
                                                          WHERE IdMoneda = @IdMoneda_Actual ) ;

                                SET @MONEDA = ( SELECT TipoMonedaCorto FROM  dbo.PV_TipoMoneda WHERE
                                                        IdMoneda = @IdMoneda                ) ;
                                SET @Detalle
                                    = CONCAT( @Detalle , ' *Cambio moneda de: ' , ISNULL ( @MONEDA_ACTUAL, '' ) , ' a: '
                                        , ISNULL ( @MONEDA, '' ) , ' ' ) ;
                            END ;

                        IF ISNULL ( @ComentarioSubcontratista_Actual, '' ) <> @ComentarioSubcontratista
                            BEGIN
                                SET @Detalle
                                    = CONCAT( @Detalle , ' *Cambio comentario de: '
                                        , ISNULL ( @ComentarioSubcontratista_Actual, '' ) , ' a: '
                                        , ISNULL ( @ComentarioSubcontratista, '' ) , ' ' ) ;
                            END ;

                        IF @FechaVigencia_Actual <> @FechaVigencia
                            BEGIN
                                SET @Detalle
                                    = CONCAT( @Detalle , ' *Cambio fecha vigencia cotización de: '
                                        , CAST(ISNULL ( @FechaVigencia_Actual, '' ) AS NVARCHAR (MAX)) , ' a: '
                                        , CAST(ISNULL ( @FechaVigencia, '' ) AS NVARCHAR (MAX)) , ' ' ) ;
                            END

                        IF @FechaEntrega_Actual <> @FechaEntrega
                            BEGIN
                                SET @Detalle
                                    = CONCAT( @Detalle , ' *Cambio fecha entrega cotización de: '
                                        , CAST(ISNULL ( @FechaEntrega_Actual, '' ) AS NVARCHAR (MAX)) , ' a: '
                                        , CAST(ISNULL ( @FechaEntrega, '' ) AS NVARCHAR (MAX)) , ' ' ) ;
                            END ;

                        IF ISNULL(@IdCondicionDePago_Actual,0) <> @IdCondicionPago 
                        BEGIN 
                            SET @Detalle
                                    = CONCAT( @Detalle , ' *Cambio condicion de pago de: '
                                        , CAST(ISNULL ((SELECT CondicionPago FROM dbo.MM_CondicionPago WHERE IdCondicionPago=ISNULL(@IdCondicionDePago_Actual,0)), '' ) AS NVARCHAR (MAX)) , ' a: '
                                        , CAST(ISNULL ( (SELECT CondicionPago FROM dbo.MM_CondicionPago WHERE IdCondicionPago=ISNULL(@IdCondicionPago,0)), '' ) AS NVARCHAR (MAX)) , ' ' ) ;
                        END 

                        IF ISNULL(@DiasCredito_Actual,0) <>  @DiasCredito
                        BEGIN 
                            SET @Detalle
                                    = CONCAT( @Detalle , ' *Cambio días de crédito de: '
                                        , CAST(ISNULL (@DiasCredito_Actual, 0) AS NVARCHAR (MAX)) , ' a: '
                                        , CAST(ISNULL (@DiasCredito,0) AS NVARCHAR (MAX)) , ' ' ) ;
                        END 

                        SET @Subtotal = @PrecioUnitario * @DisponibilidadNEW ;
                        ---VALIDACIÓN CARSO

                IF @EsProveedorDeCARSO > 0
                BEGIN 
                --ES PROVEEDOR CARSO
                SET @MaterialCotizadoTextC = (   SELECT 
                                                 DescripcionCorta                                               
                                                 FROM dbo.MM_Material
                                                 WHERE IdMaterial = @IdMaterialVendedor )
                END 
                ELSE 
                BEGIN 
                -- NO ES PROVEEDOR CARSO
                        SET @MaterialCotizadoTextC = (   SELECT CONCAT (DescripcionCorta,
                                                            ' Marca: ', CASE WHEN ISNULL(LEN(Marca),0)>0 THEN Marca ELSE ' S/M' END,
                                                            ' Modelo: ', CASE WHEN ISNULL(LEN(Modelo),0)>0 THEN Modelo ELSE ' S/M' END,
                                                            ' No. Parte: ',CASE WHEN ISNULL(LEN(NumeroParte),0)>0 THEN NumeroParte  ELSE ' S/NP' END )                                                            
                                                           FROM dbo.MM_Material
                                                          WHERE IdMaterial = @IdMaterialVendedor )
                END 

                SET @MaterialCotizadoTextL = (   SELECT DescripcionLarga
                                                    FROM dbo.MM_Material
                                                    WHERE IdMaterial = @IdMaterialVendedor )

                SET @UnidadCotizada = (   SELECT    Unidad
                                            FROM    dbo.PV_MM_MaterialUnidad
                                            WHERE    IdUnidad = @IdUnidadVendedor )
						

                        UPDATE  [dbo].[MM_PeticionOfertaDetalle]
                           SET  [PrecioUnitario] = CAST(@PrecioUnitario AS NUMERIC (18, 2)) ,
                                [ComentarioSubcontratista] = @ComentarioSubcontratista, 
								[ModificadoPor] = @IdUsuario ,
                                [ModificadoEl] = GETDATE (), 
								[IdMoneda] = @IdMoneda ,
                                [Disponibilidad] = @DisponibilidadNEW, 
								[Cotizado] = 1, 
								[SubTotal] = @Subtotal ,
                                [FechaVigencia] = @FechaVigencia, 
								[ModificadoProveedorPor] = @IdProveedorActual ,
                                [IdMaterialVendedor] = @IdMaterialVendedor, 
								[NoCotizar] = @NoCotizar ,
                                [IdUnidadProveedor] = @IdUnidadVendedor, 
								[UnidadProveedor] = @UnidadCotizada ,
                                [MaterialCotizadoTextoC] = @MaterialCotizadoTextC ,
                                [MaterialCotizadoTextoL] = @MaterialCotizadoTextL, 
								FechaEntrega = @FechaEntrega,
                                [IdCondicionPago]=@IdCondicionPago,
                                [DiasCredito]= @DiasCredito
                         WHERE  [IdPeticionOfertaDetalle] = @IdPeticionOfertaDetalle ;

                        INSERT INTO MM_HistorialEdicionCotizacion
                            ( [IdEdicionCotizacion], [IdUsuario], [IdProveedor], [Fecha], [IdPeticionOfertaDetalle] ,
                              [Descripcion] )
                        VALUES
                            ( @IdEdicionCotizacion, @IdUsuario, @IdProveedorActual, GETDATE () ,
                              @IdPeticionOfertaDetalle , ISNULL ( @Detalle, 'Texto no identificado.' )) ;

                        SELECT 'SUCCESS'  ;
                    END
            END

        --#EDICION NO COTIZAR CON EDICION
        IF @NoCotizar = 1
           AND  @IdEdicionCotizacion <> 0
           AND  @IdEstatusEdicionCotizacion = 1
            BEGIN

                SET @NoCotizar_Actual = (   SELECT  NoCotizar
                                              FROM  dbo.MM_PeticionOfertaDetalle
                                             WHERE  IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle ) ;

                IF @NoCotizar_Actual <> @NoCotizar
                    BEGIN
                        SELECT  @IdMaterialVendedor_Actual = IdMaterialVendedor ,
                                @PrecioUnitario_Actual = PrecioUnitario, 
								@Disponibilidad_Actual = Disponibilidad ,
                                @IdMoneda_Actual = IdMoneda ,
                                @ComentarioSubcontratista_Actual = ComentarioSubcontratista ,
                                @FechaVigencia_Actual = FechaVigencia, 
								@FechaEntrega_Actual = FechaEntrega,
                                @IdCondicionDePago_Actual=IdCondicionPago,
								@DiasCredito=DiasCredito
                          FROM  dbo.MM_PeticionOfertaDetalle
                         WHERE  IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle

                        SET @Detalle
                            = CONCAT( @Detalle , ' *Se cambio de Cotizar a No Cotizar servicio/material. Datos anteriores: ' ) ;

                        SET @Detalle
                            = CONCAT( @Detalle , ' *Material a cotizar de: '
                                , CAST(ISNULL ( @IdMaterialVendedor_Actual, 0 ) AS NVARCHAR (MAX)) , ' - '
                                , (   SELECT    CONCAT (DescripcionCorta,
                                                 ' Marca: ', CASE WHEN ISNULL(LEN(Marca),0)>0 THEN Marca ELSE ' S/M' END,
                                                 ' Modelo: ', CASE WHEN ISNULL(LEN(Modelo),0)>0 THEN Modelo ELSE ' S/M' END,
                                                 ' No. Parte: ',CASE WHEN ISNULL(LEN(NumeroParte),0)>0 THEN NumeroParte  ELSE ' S/NP' END )                                                
                                        FROM    dbo.MM_Material
                                       WHERE    IdMaterial = @IdMaterialVendedor_Actual )) ;

                        SET @Detalle
                            = CONCAT( @Detalle ,' *Precio unitario de: '
                                , CAST(ISNULL ( @PrecioUnitario_Actual, 0 ) AS NVARCHAR (MAX)) , ' ' ) ;

                        SET @Detalle
                            = CONCAT( @Detalle , ' *Disponibilidad de: '
                                , CAST(ISNULL ( @Disponibilidad_Actual, 0 ) AS NVARCHAR (MAX)) ,' ' ) ;

                        SET @MONEDA_ACTUAL = (   SELECT TipoMonedaCorto
                                                   FROM dbo.PV_TipoMoneda
                                                  WHERE IdMoneda = @IdMoneda_Actual ) ;

                        SET @Detalle = CONCAT( @Detalle , ' *Moneda de: ' + ISNULL ( @MONEDA_ACTUAL, '' ) , ' ' ) ;

                        SET @Detalle
                            = CONCAT( @Detalle , ' *Comentario de: ' , ISNULL ( @ComentarioSubcontratista_Actual, '' ), ' ' ) ;

                        SET @Detalle
                            = CONCAT( @Detalle ,' *Fecha vigencia cotización '
                                , CAST(ISNULL ( @FechaVigencia_Actual, '' ) AS NVARCHAR (MAX)) , ' ' ) ;

                        SET @Detalle
                            = CONCAT( @Detalle + ' *Fecha entrega cotización '
                                , CAST(ISNULL ( @FechaEntrega_Actual, '' ) AS NVARCHAR (MAX)) , ' ' ) ;

                        SET @Detalle
                            = CONCAT( @Detalle , ' *Condiciones de pago '
                                , (ISNULL((SELECT CondicionPago FROM dbo.MM_CondicionPago WHERE IdCondicionPago=ISNULL(@IdCondicionDePago_Actual,0)),'')) , ' ' ) ;

                        SET @Detalle
                            = CONCAT( @Detalle + ' *Días de crédito '
                                , CAST(ISNULL(@DiasCredito_Actual,0) AS NVARCHAR) , ' ' ) ;

                        UPDATE  [dbo].[MM_PeticionOfertaDetalle]
                           SET  [NoCotizar] = @NoCotizar, 
                                [PrecioUnitario] = NULL, 
                                [ComentarioSubcontratista] = NULL ,
                                [ModificadoPor] = @IdUsuario, 
                                [ModificadoEl] = GETDATE (), 
                                [IdMoneda] = NULL ,
                                [Disponibilidad] = NULL, 
                                [Cotizado] = 0, 
                                [SubTotal] = NULL, 
                                [FechaVigencia] = NULL ,
                                [ModificadoProveedorPor] = @IdProveedorActual,
                                [IdMaterialVendedor] = NULL ,
                                [IdUnidadProveedor] = NULL, 
                                [UnidadProveedor] = NULL, 
                                [MaterialCotizadoTextoC] = NULL ,
                                [MaterialCotizadoTextoL] = NULL, 
                                FechaEntrega = NULL,
                                [IdCondicionPago]=NULL,
                                [DiasCredito]= NULL
                         WHERE  [IdPeticionOfertaDetalle] = @IdPeticionOfertaDetalle

                        INSERT INTO MM_HistorialEdicionCotizacion
                            ( [IdEdicionCotizacion], [IdUsuario], [IdProveedor], [Fecha], [IdPeticionOfertaDetalle] ,
                              [Descripcion] )
                        VALUES
                            ( @IdEdicionCotizacion, @IdUsuario, @IdProveedorActual, GETDATE () ,
                              @IdPeticionOfertaDetalle , ISNULL ( @Detalle, 'Cambio no identificado.' ))
                    END
            END

            SELECT 'SUCCESS'
END
