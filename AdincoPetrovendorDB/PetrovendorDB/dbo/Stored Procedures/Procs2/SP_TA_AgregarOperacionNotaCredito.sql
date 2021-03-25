USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_TA_AgregarOperacionNotaCredito'
)
    DROP PROCEDURE SP_TA_AgregarOperacionNotaCredito;
GO
/****** Object:  StoredProcedure [dbo].[SP_TA_AgregarOperacionNotaCredito]    Script Date: 25/03/2021 12:19:56 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  Daniel A Cruz  
-- Create date: 25/03/2021  
-- Description: Permite agregar LA OPERACION de nota de crédito, con validación DEA
-- =============================================  
CREATE PROCEDURE [dbo].[SP_TA_AgregarOperacionNotaCredito]
    -- Add the parameters for the stored procedure here    
    @IdDocumento INT,
    @IdProveedor INT,
    @IdAsignador INT,
    @Descripcion NVARCHAR(MAX),
    @IdAceptacionPedido INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from  
    -- interfering with SELECT statements.  
	/*SP PARA AGREGAR LA OPERACIÓN DE UNA NOTA DE CREDITO DE MERCADEO*/
    SET NOCOUNT ON;
    DECLARE @FECHA_ACTUAL DATETIME = GETDATE();
    DECLARE @DescripcionH NVARCHAR(MAX);
    DECLARE @IdOperacion INT;
    DECLARE @IdTipoOperacion INT = 17; ---> APROBACIÓN DE NOTA DE CREDITO   
	DECLARE @ID_OPERADORA INT = ( SELECT IdProveedor FROM dbo.MM_AceptacionPedido WHERE IdAceptacionPedido = @IdAceptacionPedido);
    
	-- CONSULTAR EL FLUJO DE APROBACIÓN PREDETERMINADO DE ACEPTACIÓN DE FACTURA (FLUJO DE LA OPERADORA)
    DECLARE @IdFlujoAprobacion INT;

	/*VALIDACIÓN FLUJO DEA PARA VALIDAR SI SE ASIGNA EL FLUJO DEL CENTRO DE COSTO RELACIONADO DESDE EL CENTRO DE COSTO SELECIONADO EN LA REQUISICION*/
	IF EXISTS (SELECT 1 FROM dbo.DEA_Proveedor WHERE IdProveedor =@ID_OPERADORA)
	BEGIN
				-- CONSULTAMOS EL FLUJO DE APROBACION DE LA FACTURA RELACIONADO CON EL CENTRO DE COSTO DE LA REQUISICION
			       SELECT @IdFlujoAprobacion=
						RCFA.IdFlujoFactura 
					FROM dbo.MM_SolicitudPedido SP
					LEFT JOIN dbo.MM_Pedido P 
						ON P.IdSolicitudPedido = SP.IdSolicitudPedido
					LEFT JOIN dbo.MM_AceptacionPedido AP 
						ON AP.IdPedido = P.IdPedido
					LEFT JOIN dbo.MM_SolicitudPedidoDetalle SPD
						ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido
					LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPDL
						ON SPDL.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
					LEFT JOIN dbo.RelacionCentroCostoFlujoAprob RCFA 
						ON RCFA.IdCentroCosto = SPDL.IdCentroCosto
					WHERE AP.IdAceptacionPedido = @IdAceptacionPedido 
						AND RCFA.IdFlujoFactura IS NOT NULL
						AND RCFA.Activo = 1
					GROUP BY RCFA.IdFlujoFactura,RCFA.IdCentroCosto;

				/*SI NO SE ENCONTRO FLUJO RELACIONADO AL CENTRO DE COSTO- ASIGNAR EL PREDERTERMINADO POR LA OPERADORA*/
				IF ISNULL(@IdFlujoAprobacion,0) = 0
					BEGIN 
					SELECT @IdFlujoAprobacion = FT.IdFlujoTarea
						FROM MM_AceptacionFactura AS AF
						JOIN MM_AceptacionPedido AS AP
							ON AF.IdAceptacionPedido= AP.IdAceptacionPedido
						JOIN MM_Pedido AS P
							ON AP.IdPedido=P.IdPedido 
						JOIN S_Proveedor AS PR
							ON P.IdProveedorCompras=PR.IdProveedor 
						JOIN TA_FlujoTarea AS FT
							ON  P.IdProveedorCompras=FT.IdProveedor
						WHERE AP.IdAceptacionPedido = @IdAceptacionPedido
						  AND FT.IdTipoOperacion = 10 --> ACEPTACIÓN DE FACTURA
						  AND FT.Activo = 1 --> QUE ESTE ACTIVO
						  AND FT.Predeterminado = 1; --> QUE SEA EL PREDETERMINADO
					END 

	END
	ELSE
	BEGIN
	
		    SELECT @IdFlujoAprobacion = FT.IdFlujoTarea
			FROM MM_AceptacionFactura AS AF
			JOIN MM_AceptacionPedido AS AP
				ON AF.IdAceptacionPedido= AP.IdAceptacionPedido
			JOIN MM_Pedido AS P
				ON AP.IdPedido=P.IdPedido 
			JOIN S_Proveedor AS PR
				ON P.IdProveedorCompras=PR.IdProveedor 
			JOIN TA_FlujoTarea AS FT
				ON  P.IdProveedorCompras=FT.IdProveedor
			WHERE AP.IdAceptacionPedido = @IdAceptacionPedido
			  AND FT.IdTipoOperacion = 10 --> ACEPTACIÓN DE FACTURA
			  AND FT.Activo = 1 --> QUE ESTE ACTIVO
			  AND FT.Predeterminado = 1; --> QUE SEA EL PREDETERMINADO

	END 

	
    INSERT INTO TA_Operacion
    (
        IdDocumento,
        IdTipoOperacion,
        IdFlujoTarea,
        IdEstatusOperacion,
        IdEstadoFlujo,
        IdProveedor,
        IdAsignador,
        FechaRegistro,
        Descripcion,
        IdVigencia,
        IdPrioridad
    )
    VALUES
    (@IdDocumento, @IdTipoOperacion, @IdFlujoAprobacion, 1, 1, @IdProveedor, @IdAsignador, @FECHA_ACTUAL, @Descripcion,
     NULL, NULL);


    SELECT @IdOperacion = (SCOPE_IDENTITY());

    ----Agregar Evento al Historial del Flujo de Tarea----  

    SET @DescripcionH
        = N'El Usuario ' +
          (
              SELECT Nombre FROM S_Usuario WHERE IdUsuario = @IdAsignador
          ) + N' ha registrado la Tarea de Tipo ' +
          (
              SELECT NombreOperacion
              FROM TA_TipoOperacion
              WHERE IdTipoOperacion = @IdTipoOperacion
          );

    INSERT INTO TA_HistorialFlujoTarea
    (
        IdOperacion,
        Fecha,
        Descripcion,
        IdEstadoFlujo
    )
    VALUES
    (@IdOperacion, @FECHA_ACTUAL, @DescripcionH, 1);


    --AGREGAR APROBADORES   
	--PARA LOS APROBADORES QUE SON SERIALES SE LE AGREGAR EL ESTATUS EN APROBACIÓN 
	--Y A LAS SIGUIENTES SE LES AGREGA EL ESTATUS SIN INCIAR APROBACIÓN
	--SI SON PARALELOS TODOS TIENE ESTATUS EN APROBACIÓN
    INSERT INTO dbo.TA_Tarea
    (
        NombreTarea,
        FechaRegistro,
        IdEstatus,
        Activo,
        Visto,
        IdAprobador,
        NoSecuencia,
        IdOperacion
    )
    SELECT 'Aprobación de Factura NC',
           GETDATE(),
           CASE
               WHEN FT.IdTipoFlujo = 1 --> APROBACIÓN SERIAL  
                    AND A.NoSecuencia > 1 THEN
                   9 --> SIN INICIAR APROBACIÓN SOLO APLICA PARA SERIALES DONDE NUM SECUENCIA ES MAYOR A 1   
               ELSE
                   1 --> EN APROBACIÓN  
           END,
           1,
           0,
           A.IdUsuario,
           A.NoSecuencia,
           @IdOperacion
    FROM dbo.TA_Aprobador A
        LEFT JOIN dbo.TA_FlujoTarea FT
            ON FT.IdFlujoTarea = A.IdFlujoTarea --SELECT * FROM dbo.TA_TipoFlujoTarea  
    WHERE A.IdFlujoTarea = @IdFlujoAprobacion
    ORDER BY A.NoSecuencia ASC;

    SELECT @IdOperacion AS IdOperacion;

    --RETORNAR ARPOBADORES PARA ENVIAR NOTIFICACIONES
    SELECT AD.IdTarea,                 --0  
           AD.IdAprobador,             --1  
           U.Nombre,                   --2  
           U.Correo,                   --3  
           AD.IdOperacion,             --4  
           AD.NoSecuencia,             --5  
           PG.IdPedido,                --6  
           AP.IdAceptacionPedido,      --7  
           NC.IdAceptacionNotaCredito, --8  
           P.IdSolicitudPedido,        --9  
           P.IdPedido
    FROM dbo.TA_Tarea AD
        JOIN dbo.TA_Operacion A
            ON AD.IdOperacion = A.IdOperacion
        JOIN dbo.S_Usuario U
            ON AD.IdAprobador = U.IdUsuario
        JOIN dbo.MM_AceptacionNotaCredito NC
            ON A.IdDocumento = NC.IdAceptacionNotaCredito
        JOIN dbo.MM_AceptacionPedido AP
            ON NC.IdAceptacionPedido = AP.IdAceptacionPedido
        INNER JOIN dbo.MM_Pedido P
            ON AP.IdPedido = P.IdPedido
        JOIN dbo.MM_Pedidos PG
            ON P.IdPedido = PG.IdIdentificador
               AND PG.IdProveedorCliente = P.IdProveedorCompras
    WHERE A.IdOperacion = @IdOperacion
          AND AD.IdEstatus = 1 ---> PARA QUE SOLO MANDE NOTIFICACIÓN A LOS APROBADORES QUE ESTAN PENDIENTES DE APROBAR YA SERA SERIAL PARALELO  
          AND A.IdTipoOperacion = 17 -->Aprobación de nota de crédito  
    GROUP BY AD.IdTarea,                 --0  
             AD.IdAprobador,             --1  
             U.Nombre,                   --2  
             U.Correo,                   --3  
             AD.IdOperacion,             --4  
             AD.NoSecuencia,             --5  
             PG.IdPedido,                --6  
             AP.IdAceptacionPedido,      --7  
             NC.IdAceptacionNotaCredito, --8  
             P.IdSolicitudPedido,        --9  
             P.IdPedido;

END;
