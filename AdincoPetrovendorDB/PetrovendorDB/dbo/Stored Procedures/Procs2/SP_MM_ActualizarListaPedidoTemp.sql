-- =============================================
-- Author:		Daniel AC
-- Create date: 25-10-2019
-- Description:	Se agrega configuración para días de credito temporal para usarlo en la configuración de generar pedido
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_ActualizarListaPedidoTemp]

-- Add the parameters for the stored procedure here

@IdPeticionOfertaDetalle INT, 
@AddPedidoTemp           BIT, 
@AddCantidadTemp         FLOAT, 
@IdProveedor             INT, 
@IdUsuario               INT
AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.

        SET NOCOUNT ON;
        DECLARE @PRECIO_UNITARIO FLOAT;
        DECLARE @SUB_TOTAL FLOAT;
        DECLARE @ID_PETICION_OFERTA INT;
        DECLARE @ID_MATERIAL_SOLICITADO INT;
        DECLARE @ID_MMAESTRO INT;
        DECLARE @ADD_MM_ADD_PETICION_OFERTA FLOAT;
        DECLARE @ADD_MM_SOLICITADOS_PETICION_OFERTA FLOAT;
        DECLARE @ADJUDICACION_PARCIAL BIT;
        DECLARE @ADD_PETICION_OFERTA_DETALLE_ACTUAL FLOAT;
        DECLARE @ID_SOL_PED_DETALLE_ACTUAL INT;
        DECLARE @MATERIALES_FALTANTES FLOAT;
        DECLARE @CM_DISPONIBLES FLOAT;
        DECLARE @ID_CONDICIONPAGO INT;
        DECLARE @DIAS_CREDITO INT;

        ---#AGREGAR a la lista de Pedido
        IF @AddPedidoTemp = 1
            BEGIN

                ---#VALIDAR CANTIDADES ----

                SET @ID_PETICION_OFERTA =
                (
                    SELECT IdPeticionOferta
                    FROM MM_PeticionOfertaDetalle
                    WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
                );
                SET @ID_CONDICIONPAGO =
                (
                    SELECT IdCondicionPago
                    FROM MM_PeticionOfertaDetalle
                    WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
                );
                SET @DIAS_CREDITO =
                (
                    SELECT DiasCredito
                    FROM MM_PeticionOfertaDetalle
                    WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
                );

                -- SI @ID_CONDICIONPAGO DE LA COTIZACIÓN DETALLE ES NULL PONER COMO DEFAULT AL CONTADAO Y  0 DIAS DE CREDITO 
                IF ISNULL(@ID_CONDICIONPAGO, 0) = 0
                    BEGIN
                        SET @ID_CONDICIONPAGO = 2; --> SELECT * FROM dbo.MM_CondicionPago WHERE IdCondicionPago=2
                        SET @DIAS_CREDITO = 0;
                END;
                SET @ID_MMAESTRO =
                (
                    SELECT IdMaterial
                    FROM MM_PeticionOfertaDetalle
                    WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
                );
                SET @ID_SOL_PED_DETALLE_ACTUAL =
                (
                    SELECT IdSolicitudPedidoDetalle
                    FROM MM_PeticionOfertaDetalle
                    WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
                );
                SET @ADD_MM_ADD_PETICION_OFERTA =
                (
                    SELECT SUM(POD.AddCantidadTemp)
                    FROM MM_PeticionOfertaDetalle AS POD
                         INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOferta = POD.IdPeticionOferta
                         INNER JOIN MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
                         INNER JOIN MM_Maestro AS MM ON MM.IdMaestro = SPD.IdMaterial
                    WHERE POD.IdSolicitudPedidoDetalle = @ID_SOL_PED_DETALLE_ACTUAL
                          AND POD.AddValidado = 1
                );
                SET @ADD_MM_SOLICITADOS_PETICION_OFERTA =
                (
                    SELECT POD.NoMaterialesRequeridos
                    FROM MM_PeticionOfertaDetalle AS POD
                    WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
                );
                SET @ADJUDICACION_PARCIAL =
                (
                    SELECT SP.AdjudicableParcialmente
                    FROM MM_SolicitudPedido AS SP
                         INNER JOIN MM_PeticionOferta AS PO ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
                    WHERE PO.IdPeticionOferta = @ID_PETICION_OFERTA
                );
                SET @ADD_PETICION_OFERTA_DETALLE_ACTUAL =
                (
                    SELECT POD.AddCantidadTemp
                    FROM MM_PeticionOfertaDetalle AS POD
                    WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
                          AND AddValidado = 1
                );
                CREATE TABLE #CM_ESTATUS
                (CantidadSolicita                    FLOAT, 
                 CantidadPorAgregarPedido            FLOAT, 
                 CantidadEnPedidoAprobacion          FLOAT, 
                 CantidadEnAprobacionRechazada       FLOAT, 
                 CantidadEnConfirmacion              FLOAT, 
                 CantidadEnConfirmacionAceptada      FLOAT, 
                 CantidadEnConfirmacionRechazada     FLOAT, 
                 CantidadEnConfirmacionItemRechazada FLOAT, 
                 CantidadPorSolicitar                FLOAT, 
                 MaterialSolicitado                  NVARCHAR(MAX), 
                 CantidadRecibidaPedidoCerrado       FLOAT
                );
                DECLARE @FECHACONSULTA DATETIME= GETDATE();
                INSERT INTO #CM_ESTATUS
                EXEC dbo.SP_MM_ConsultarEstatusCantidadesMaterialSPD_MV1_5 
                     @IdSolicitudPedidoDetalle = @ID_SOL_PED_DETALLE_ACTUAL, -- int
                     @IdContrato = 0, -- int
                     @IdUsuario = 0, -- int
                     @FechaRegistro = @FECHACONSULTA; -- datetime
                --DECLARE @CotVencida BIT;
                --SET @CotVencida = (
                --		SELECT
                --		( CASE WHEN ( DATEDIFF ( MINUTE, POD.FechaVigencia, GETDATE ())) <= 0 THEN
                --			0
                --		ELSE
                --			1
                --		END ) AS POD_Vencida
                --		FROM dbo.MM_PeticionOfertaDetalle POD
                --		WHERE POD.IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle 
                --	)
                --DECLARE @descripcion NVARCHAR(MAX) = 'El usuario ' + LTRIM( @IdUsuario ) + ' a registrado un material/servicio de una cotización vencida';

                SET @MATERIALES_FALTANTES =
                (
                    SELECT TOP 1 CantidadPorSolicitar
                    FROM #CM_ESTATUS
                );
                ---#ADJUDICACION_UNICA ---

                IF @ADJUDICACION_PARCIAL = 1
                    BEGIN 
                        -- CONSULTAR LA CANTIDAD DISPONIBLE DE LA COTIZACIÓN DETALLE ACTUAL 
                        EXEC SP_MM_ConsultarDisponibilidadPOD 
                             @IdPeticionOfertaDetalle, 
                             @ID_SOL_PED_DETALLE_ACTUAL, 
                             @CM_DISPONIBLES OUTPUT;

                        -- VALIDAR LA DISPONIBILIDAD DE LA COTIZACIÓN DEL PROVEEDOR QUE NO SOBREPASE LA CANTIDAD INGRESADA 					
                        IF CAST(ISNULL(@CM_DISPONIBLES, 0) AS DECIMAL(12, 2)) >= CAST(ISNULL(@AddCantidadTemp, 0) AS DECIMAL(12, 2))
                            BEGIN
                                DECLARE @MATERIALES_ADJ_DISPONIBLES DECIMAL(12, 2);
                                SET @MATERIALES_ADJ_DISPONIBLES = (ISNULL(@MATERIALES_FALTANTES, 0) + ISNULL(@ADD_PETICION_OFERTA_DETALLE_ACTUAL, 0));
                                --VALIDAR QUE LA CANTIDAD SOLICITADA NO SOBREPASE LA CANTIDAD AGREGADA 
                                -- COMO EN @CM_DISPONIBLES NO SE TOMAN EN CUENTA LOS MATERIALES EN ORDEN DE COMPRA TEMPORAL SE DEBEN SUMAR A LA DISPONIBLIDAD ACTUAL

                                IF(@MATERIALES_ADJ_DISPONIBLES >= CAST(ISNULL(@AddCantidadTemp, 0) AS DECIMAL(12, 2)))
                                    BEGIN
                                        SET @PRECIO_UNITARIO =
                                        (
                                            SELECT PrecioUnitario
                                            FROM MM_PeticionOfertaDetalle
                                            WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
                                        );
                                        SET @SUB_TOTAL = @PRECIO_UNITARIO * @AddCantidadTemp;

                                        ---#ACTUALIZAR CANTIDADES ----
                                        UPDATE MM_PeticionOfertaDetalle
                                          SET 
                                              [AddPedidoTemp] = @AddPedidoTemp, 
                                              [AddCantidadTemp] = @AddCantidadTemp, 
                                              [AddValidado] = 1, 
                                              AddSubTotalTemp = @SUB_TOTAL, 
                                              DiasCreditoTemp = @DIAS_CREDITO, 
                                              IdCondicionPagoTemp = @ID_CONDICIONPAGO
                                        WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle;

                                        -- registra el historial cuando se agrega un material de una cotizacion vencida
                                        --IF @CotVencida = 1
                                        --BEGIN
                                        --		EXEC dbo.SP_PA_InsHistorialProcesoAbierto 
                                        --		@IdProveedor = @IdProveedor,     -- int
                                        --        @IdUsuario = @IdUsuario,       -- int
                                        --        @IdTabla = @IdPeticionOfertaDetalle,         -- int
                                        --        @IdHistorialTipo = 1, -- int
                                        --        @IdOperacion = 0,     -- int
                                        --        @Descripcion = @descripcion    -- nvarchar(max)
                                        --END

                                        SELECT 'UPDATE_ADD_PEDIDO_SUCCESS';
                                END;
                                    ELSE
                                    BEGIN
                                        SELECT 'ERROR_CANTIDAD_MAYOR_A_REQUERIDA_ADJ_PARCIAL';
                                END;
                        END;
                            ELSE
                            BEGIN
                                SELECT 'ERROR_CANTIDAD_INGRESADA_MAYOR_A_DISPONIBILIDAD_PROVEEDOR';
                        END;
                END;
                    ELSE
                    BEGIN

                        ---#ADJUDICACION UNICA -
                        DECLARE @MATERIALES_UNICA_DISPONIBLES DECIMAL(12, 2);
                        SET @MATERIALES_UNICA_DISPONIBLES = (ISNULL(@MATERIALES_FALTANTES, 0) + ISNULL(@ADD_PETICION_OFERTA_DETALLE_ACTUAL, 0));
                        ---VALIDAR QUE LA CANTIDAD NO SOBREPASE LA CANTIDAD SOLICITADA 
                        --- EN ADJUDICACIÓN ÚNICA SE DEBE AGREGAR A LA ORDEN DE COMPRA LA CANTIDAD INDICADA EN LA SOLPED DETALLE ACTUAL

                        IF(@MATERIALES_UNICA_DISPONIBLES = CAST(ISNULL(@AddCantidadTemp, 0) AS DECIMAL(12, 2)))
                            BEGIN
                                SET @PRECIO_UNITARIO =
                                (
                                    SELECT PrecioUnitario
                                    FROM MM_PeticionOfertaDetalle
                                    WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
                                );
                                SET @SUB_TOTAL = @PRECIO_UNITARIO * @AddCantidadTemp;

                                ---#ACTUALIZAR CANTIDADES ----
                                UPDATE MM_PeticionOfertaDetalle
                                  SET 
                                      [AddPedidoTemp] = @AddPedidoTemp, 
                                      [AddCantidadTemp] = @AddCantidadTemp, 
                                      [AddValidado] = 1, 
                                      AddSubTotalTemp = @SUB_TOTAL, 
                                      DiasCreditoTemp = @DIAS_CREDITO, 
                                      IdCondicionPagoTemp = @ID_CONDICIONPAGO
                                WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle;

                                -- registra el historial cuando se agrega un material de una cotizacion vencida
                                --IF @CotVencida = 1
                                --BEGIN
                                --		EXEC dbo.SP_PA_InsHistorialProcesoAbierto 
                                --		@IdProveedor = @IdProveedor,     -- int
                                --		@IdUsuario = @IdUsuario,       -- int
                                --		@IdTabla = @IdPeticionOfertaDetalle,         -- int
                                --		@IdHistorialTipo = 1, -- int
                                --		@IdOperacion = 0,     -- int
                                --		@Descripcion = @descripcion    -- nvarchar(max)
                                --END

                                SELECT 'UPDATE_ADD_PEDIDO_SUCCESS';
                        END;
                            ELSE
                            BEGIN
                                SELECT 'ERROR_ADD_PEDIDO_ADJ_UNICA';
                        END;
                END;
        END;
            ELSE
        ---#REMOVER de la lista de pedido
            BEGIN
                UPDATE MM_PeticionOfertaDetalle
                  SET 
                      [AddPedidoTemp] = @AddPedidoTemp, 
                      [AddCantidadTemp] = NULL, 
                      [AddSubTotalTemp] = NULL, 
                      AddValidado = 0, 
                      DiasCreditoTemp = NULL, 
                      IdCondicionPagoTemp = NULL
                WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle;
                SELECT 'UPDATE_REMOVE_PEDIDO_SUCCESS';
        END;
    END;
