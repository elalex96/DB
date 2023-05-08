-- =============================================
-- Author:		Daniel AC
-- Update: 08-10-2020
-- Description:	Revisión issue #759/Se agrego filtro pedido (2-Mercadeo, 4-AD, 6-OT)
-- =============================================
-- =============================================
-- Author:		Luis David De La Cruz Bautista
-- Update:		---01-2021
-- Description:	Revisión issue #920/ Optimización de sp
-- =============================================
-- Author:		Luis David De La Cruz Bautista
-- Update:		25/01/2021
-- Description:	Revisión issue #930/ Optimización de sp
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaPedidosCliente] --907,'TODOS',3296
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,
    @Filtro NVARCHAR(100),
    @IdUsuario INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    --PARA OBTENER EL NUMERO DE PEDIDO QUE VISUALIZA EL PROVEEDOR 
    --EL MM_PEDIDO.IdPedido es el identificador unico de un pedido (Control interno)
    --El MM_PEDIDOS.IdPedido es el identificador consecutivo de un pedido por proveedor (Este el el # visible para el proveedor)
    --El MM_PEDIDOS.IdIdentificador es la relación con MM_PEDIDO.IdPedido 
    --El MM_PEDIDOS.IdProveedorCliente es la relación con MM_PEDIDO.IdProveedorCompras (Es el proveedor de la operadora)
    --El MM_PEDIDOS.IdTipoPedido es el tipo de pedido 
    --	LOS PEDIDOS SE DEBEN FILTRAR POR EL TIPO DE PEDIDO 
    --  MM_PEDIDOS.IdTipoPedido = 2 --> Pedido de Tipo Mercadeo
    --  MM_PEDIDOS.IdTipoPedido = 4 --> Pedido de Tipo Adjudicación directa
    --  PGMM_PEDIDOSIdTipoPedido = 6 --> Pedido de Tipo Orden de trabajo
    -- AQUI SE EXCLUYEN LOS DEMAS PEDIDOS POR QUE
    --> COMPRA DIRECTA TIENE SU PROPIO CONSECUTIVO 
    --> COMPROBANTE DE COMPrA TIENE SU PROPIO CONSECUTIVO 
    --> Y PODRIAN CONCIDIR Y DUPLICAR RESULTADOS 
    -->LAS APROBACIONES DE PEDIDO SE FILTRAN POR TIPO DE OPERACIÓN, IDDOCUMENTO Y NUMERO DE VERSIÓN 
    /*TA_Operacion.IdTipoOperacion= 9 (APROBACIÓN DE PEDIDO -->TA_TipoOperacion)
	  TA_Operacion.IdDocumento = MM_PEDIDO.IdSolicitudPedido 
	  TA_Operacion.NoVersion=MM_PEDIDO.Version=*/

	CREATE TABLE #WDEA_PurchasingDocumentsImportados
    (
        IdPedidoADINCO INT,
		MECANISMO_CONTRATACION NVARCHAR(MAX)
    );
    DECLARE @EsAdministradorCompras BIT = 0, @EsTipoAdministrador BIT = 0, @EsAdministrador BIT = 0;

    --CONSULTAR SI EL USUARIO ACTUAL ES ADMINISTRADOR DE COMPRAS
    SELECT @EsAdministradorCompras = Activo
    FROM dbo.CC_AdministradorCompras  (NOLOCK)
    WHERE IdUsuario = @IdUsuario
          AND Activo = 1
          AND IdProveedor = @IdProveedor;

    --CONSULTAR SI EL USUARIO ACTUAL ES USUARIO DE TIPO ADMINISTRADOR 
    SELECT @EsTipoAdministrador = CASE
                                      WHEN COUNT(1) > 0 THEN
                                          1
                                      ELSE
                                          0
                                  END
    FROM dbo.S_Usuario U  (NOLOCK)
    WHERE U.IdTipoUsuario IN ( 3, 4, 6, 7, 8 ) --> CTES Administrador,Ventas,Director General,Root
          AND U.IdUsuario = @IdUsuario;

    --SI CUMPLE ALGUNO DE ESTOS PARAMETROS ES UN ADMINISTRADOR Y PUEDE VER TODAS LAS PETICIONES DE SOL OFERTA
    -- SI NO SOLO PODRÁ VER LOS PEDIDOS DE LAS SOL OFERTA DONDE FUE ASIGNADO
    IF @EsTipoAdministrador = 1
       OR @EsAdministradorCompras = 1
    BEGIN
        SET @EsAdministrador = 1;
    END;

    CREATE TABLE #MM_SolicitudPedidoCompradorT
    (
        IdSolicitudPedido INT
    );
    INSERT INTO #MM_SolicitudPedidoCompradorT
    (
        IdSolicitudPedido
    )
    SELECT P.IdSolicitudPedido
    FROM dbo.MM_Pedido P (NOLOCK)
        INNER JOIN dbo.MM_SolicitudPedido SP (NOLOCK)
            ON P.IdSolicitudPedido = SP.IdSolicitudPedido
        INNER JOIN dbo.MM_SolicitudPedidoComprador SPC (NOLOCK)
            ON P.IdSolicitudPedido = SPC.IdSolicitudPedido
    WHERE SPC.IdAsignadoA = @IdUsuario
          AND ISNULL(SPC.Activo, 0) = 1 -->CTE QUE ESTE ACTIVO
    GROUP BY P.IdSolicitudPedido;

	-- FILTRAR TODOS LOS PEDIDOS DEL PROVEEDOR ACTUAL
	INSERT INTO #WDEA_PurchasingDocumentsImportados(IdPedidoADINCO,MECANISMO_CONTRATACION)
	SELECT PDI.IdPedidoADINCO,MAX(PDI.MECANISMO_CONTRATACION)
	FROM MM_Pedido P
	JOIN  WDEA_PurchasingDocumentsImportados PDI
		ON P.IdPedido = PDI.IdPedidoADINCO
	WHERE P.IdProveedorCompras= @IdProveedor
	GROUP BY PDI.IdPedidoADINCO

    IF @Filtro = 'EN_APROBACION'
    BEGIN

        SELECT P.IdPedido,
               P.IdSolicitudPedido,
               P.CreadoEl AS FechaEnvioPedido,
               SUM(PD.Subtotal) AS TotalPedido,
               ISNULL(PV.RazonSocial, '') + ' ' + ISNULL(PV.RegimenCapital, '') AS Proveedor,             
               E.Nombre,
               P.Version,
               P.RecepcionServicio,
               TM.TipoMonedaCorto AS TipoMoneda,
               PG.IdPedido AS IdPedidoGeneral,
               CASE WHEN ISNULL(PDI.MECANISMO_CONTRATACION,'')='L' THEN 
				'Licitación'
			   ELSE 
				TP.TipoPedido
			   END AS TipoPedido,
               TP.IdTipoPedido,
               (
                   SELECT STUFF(
                          (
                              SELECT CAST(', ' AS VARCHAR(MAX)) + CONVERT(NVARCHAR(MAX), ISNULL(U.Nombre, '')),
                                     Contrato = c.NumeroContrato
                              FROM dbo.MM_SolicitudPedidoComprador SPC
                                  INNER JOIN dbo.S_Usuario U
                                      ON SPC.IdAsignadoA = U.IdUsuario
                              WHERE SPC.IdSolicitudPedido = P.IdSolicitudPedido
                                    AND SPC.Activo = 1
                              ORDER BY U.Nombre ASC
                              FOR XML PATH('')
                          ),
                          1,
                          1,
                          ''
                               )
               ) AS Asignados,
               Contrato = C.NumeroContrato
        FROM MM_Pedido AS P (NOLOCK)
            JOIN MM_PedidoDetalle AS PD (NOLOCK)
                ON P.IdPedido = PD.IdPedido
				AND ISNULL(P.IdEstatusEliminado, 0) <> 1 --> QUE NO ESTE ELIMINADO EL PEDIDO
				AND ISNULL(P.Cerrado, 0) = 0 --> PEDIDOS NO CERRADOS
            JOIN dbo.MM_SolicitudPedido SP (NOLOCK)
                ON P.IdSolicitudPedido = SP.IdSolicitudPedido
            JOIN MM_PeticionOferta AS PO  (NOLOCK)
                ON P.IdPeticionOferta = PO.IdPeticionOferta
            JOIN S_Proveedor AS PV  (NOLOCK)
                ON P.IdSubcontratista = PV.IdProveedor
            JOIN TA_Operacion AS O  (NOLOCK)
                ON P.IdSolicitudPedido = O.IdDocumento
				AND O.IdTipoOperacion = 9 --> CTE APROBACIÓN DE PEDIDO
				AND O.IdProveedor = @IdProveedor
            JOIN TA_Prioridad AS PR  (NOLOCK)
                ON O.IdPrioridad = PR.IdPrioridad
            JOIN TA_Vencimiento AS V  (NOLOCK)
                ON O.IdVigencia = V.IdVencimiento
            JOIN TA_TipoOperacion AS TTO  (NOLOCK)
                ON O.IdTipoOperacion = TTO.IdTipoOperacion
            JOIN TA_Estatus AS E  (NOLOCK)
                ON O.IdEstatusOperacion = E.IdEstatus
            JOIN MM_HorasVigenciaPedido AS HV  (NOLOCK)
                ON P.IdPedido = HV.IdPedido
            JOIN PV_TipoMoneda AS TM  (NOLOCK)
                ON P.IdMoneda = TM.IdMoneda
            JOIN MM_Pedidos AS PG  (NOLOCK)
                ON P.IdPedido = PG.IdIdentificador
                   AND @IdProveedor = PG.IdProveedorCliente
                   AND PG.IdTipoPedido IN ( 2, 4, 6 ) -->(Mer, AD, OT)
            LEFT JOIN Adinco.dbo.CO_Contrato AS C  (NOLOCK)
                ON SP.IdContrato = C.IdContrato
            LEFT JOIN dbo.MM_TipoPedido AS TP  (NOLOCK)
                ON PG.IdTipoPedido = TP.IdTipoPedido
            LEFT JOIN #MM_SolicitudPedidoCompradorT SPC  (NOLOCK)
                ON P.IdSolicitudPedido = SPC.IdSolicitudPedido
			LEFT JOIN #WDEA_PurchasingDocumentsImportados PDI  (NOLOCK)
				ON  P.IdPedido = PDI.IdPedidoADINCO
        WHERE O.IdTipoOperacion = 9 --> CTE APROBACIÓN DE PEDIDO
              AND ISNULL(P.IdEstatusEliminado, 0) <> 1 --> QUE NO ESTE ELIMINADO EL PEDIDO
              AND ISNULL(P.Cerrado, 0) = 0 --> PEDIDOS NO CERRADOS
              AND O.IdProveedor = @IdProveedor
              AND P.RecepcionServicio IS NULL ---> CUANDO ES NULL NO TIENE RECEPCIÓN DE SERVICIO CONFIRMADA NI RECHAZADA
              AND O.IdEstatusOperacion = 1 --> CTE EN APROBACIÓN 
              AND HV.FechaVigencia IS NULL --> SE ASIGNA UNA VEZ APROBADO EL PEDIDO
              AND P.Version = O.NoVersion --> LA VERSIÓN DE PEDIDO DEBE SER LA MISMA QUE LA DE LA OPERACIÓN
              AND CASE
                      WHEN ISNULL(@EsAdministrador, 0) IN ( 0, 1 )
                           AND SPC.IdSolicitudPedido IS NOT NULL THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
                          1 --> MOSTRAR	  
     WHEN ISNULL(@EsAdministrador, 0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
                          1 --> MOSTRAR	  
                      WHEN SP.IdUsuarioSolicitante = @IdUsuario THEN
                          1 --> MOSTRAR	  
                      ELSE
                          0 --> NO MOSTRAR NINGUNA 
                  END = 1
        GROUP BY P.IdPedido,
                 P.IdSolicitudPedido,
                 P.CreadoEl,
                 PV.RazonSocial,
                 PV.RegimenCapital,
                 P.RecepcionServicio,
                 E.Nombre,
                 P.Version,
                 TM.TipoMonedaCorto,
                 PG.IdPedido,
                 TP.TipoPedido,
                 TP.IdTipoPedido,
                 C.NumeroContrato,
				 PDI.MECANISMO_CONTRATACION
        ORDER BY PG.IdPedido DESC;
    END;

    IF @Filtro = 'APROBADOS'
    BEGIN
        SELECT P.IdPedido,
               P.IdSolicitudPedido,
               P.FechaEnvioPedido AS FechaEnvioPedido,
               SUM(PD.Subtotal) AS TotalPedido,
               ISNULL(PV.RazonSocial, '') + ' ' + ISNULL(PV.RegimenCapital, '') AS Proveedor,              
               E.Nombre,
               P.Version,
               TM.TipoMonedaCorto AS TipoMoneda,
               PG.IdPedido AS IdPedidoGeneral,
               CASE WHEN ISNULL(PDI.MECANISMO_CONTRATACION,'')='L' THEN 
				'Licitación'
			   ELSE 
				TP.TipoPedido
			   END AS TipoPedido,
               TP.IdTipoPedido,
               (
                   SELECT STUFF(
                          (
                              SELECT CAST(', ' AS VARCHAR(MAX)) + CONVERT(NVARCHAR(MAX), ISNULL(U.Nombre, ''))
                              FROM dbo.MM_SolicitudPedidoComprador SPC
                                  INNER JOIN dbo.S_Usuario U
                                      ON SPC.IdAsignadoA = U.IdUsuario
                              WHERE SPC.IdSolicitudPedido = P.IdSolicitudPedido
                                    AND SPC.Activo = 1
                              ORDER BY U.Nombre ASC
                              FOR XML PATH('')
                          ),
                          1,
                          1,
                          ''
                               )
               ) AS Asignados,
               Contrato = C.NumeroContrato
        FROM MM_Pedido AS P  (NOLOCK)
            JOIN dbo.MM_SolicitudPedido SP  (NOLOCK)
                ON P.IdSolicitudPedido = SP.IdSolicitudPedido
            INNER JOIN MM_PedidoDetalle AS PD  (NOLOCK)
                ON P.IdPedido = PD.IdPedido
            INNER JOIN MM_PeticionOferta AS PO  (NOLOCK)
                ON P.IdPeticionOferta = PO.IdPeticionOferta
            INNER JOIN S_Proveedor AS PV  (NOLOCK)
                ON P.IdSubcontratista = PV.IdProveedor
            INNER JOIN TA_Operacion AS O  (NOLOCK)
                ON P.IdSolicitudPedido = O.IdDocumento
            INNER JOIN TA_Prioridad AS PR  (NOLOCK)
                ON O.IdPrioridad = PR.IdPrioridad
            INNER JOIN TA_Vencimiento AS V  (NOLOCK)
                ON O.IdVigencia = V.IdVencimiento
            INNER JOIN TA_TipoOperacion AS TTO  (NOLOCK)
                ON O.IdTipoOperacion = TTO.IdTipoOperacion
            INNER JOIN TA_Estatus AS E  (NOLOCK)
                ON O.IdEstatusOperacion = E.IdEstatus
            INNER JOIN MM_HorasVigenciaPedido AS HV  (NOLOCK)
                ON P.IdPedido = HV.IdPedido
            INNER JOIN PV_TipoMoneda AS TM (NOLOCK)
                ON P.IdMoneda = TM.IdMoneda
            INNER JOIN MM_Pedidos AS PG (NOLOCK)
                ON P.IdPedido = PG.IdIdentificador
                   AND @IdProveedor = PG.IdProveedorCliente 
                   AND PG.IdTipoPedido IN ( 2, 4, 6 ) -->(Mer, AD, OT)
            INNER JOIN Adinco.dbo.CO_Contrato AS C (NOLOCK)
                ON SP.IdContrato = C.IdContrato
            LEFT JOIN dbo.MM_TipoPedido AS TP (NOLOCK)
                ON PG.IdTipoPedido = TP.IdTipoPedido
            LEFT JOIN #MM_SolicitudPedidoCompradorT SPC
				ON P.IdSolicitudPedido = SPC.IdSolicitudPedido
			LEFT JOIN #WDEA_PurchasingDocumentsImportados PDI  (NOLOCK)
				ON  P.IdPedido = PDI.IdPedidoADINCO
        WHERE O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
              AND O.IdProveedor = @IdProveedor
              AND P.RecepcionServicio IS NULL ---> CUANDO ES NULL NO TIENE RECEPCIÓN DE SERVICIO CONFIRMADA NI RECHAZADA
              AND E.IdEstatus = 2 --> ESTATUS APROBADO
              AND HV.FechaVigencia IS NULL
              AND P.Version = O.NoVersion --> LA VERSIÓN DE PEDIDO DEBE SER LA MISMA QUE LA DE LA OPERACIÓN
              AND ISNULL(P.IdEstatusEliminado, 0) <> 1 --> QUE NO ESTE ELIMINADO EL PEDIDO
              AND ISNULL(P.Cerrado, 0) = 0 --> PEDIDOS NO CERRADOS
              AND CASE
                      WHEN ISNULL(@EsAdministrador, 0) IN ( 0, 1 )
                           AND SPC.IdSolicitudPedido IS NOT NULL THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
                          1
                      WHEN ISNULL(@EsAdministrador, 0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
                          1
                      WHEN SP.IdUsuarioSolicitante = @IdUsuario THEN
                          1
                      ELSE
                          0 --> NO MOSTRAR NINGUNA 
                  END = 1
        GROUP BY P.IdPedido,
                 P.IdSolicitudPedido,
                 P.FechaEnvioPedido,
                 PV.RazonSocial,
                 PV.RegimenCapital,
                 P.RecepcionServicio,
                 E.Nombre,
                 P.Version,
                 TM.TipoMonedaCorto,
                 PG.IdPedido,
                 TP.TipoPedido,
                 TP.IdTipoPedido,
                 C.NumeroContrato,
				 PDI.MECANISMO_CONTRATACION
        ORDER BY PG.IdPedido DESC;

    END;


    IF @Filtro = 'RECHAZADOS'
    BEGIN
        SELECT P.IdPedido,
               P.IdSolicitudPedido,
               P.CreadoEl AS FechaEnvioPedido,
               SUM(PD.Subtotal) AS TotalPedido,
               ISNULL(PV.RazonSocial, '') + ' ' + ISNULL(PV.RegimenCapital, '') AS Proveedor,            
               E.Nombre,
               P.Version,
               TM.TipoMonedaCorto AS TipoMoneda,
               PG.IdPedido AS IdPedidoGeneral,
               CASE WHEN ISNULL(PDI.MECANISMO_CONTRATACION,'')='L' THEN 
				'Licitación'
			   ELSE 
				TP.TipoPedido
			   END AS TipoPedido,
               TP.IdTipoPedido,
               (
                   SELECT STUFF(
                          (
                              SELECT CAST(', ' AS VARCHAR(MAX)) + CONVERT(NVARCHAR(MAX), ISNULL(U.Nombre, ''))
                              FROM dbo.MM_SolicitudPedidoComprador SPC
                                  INNER JOIN dbo.S_Usuario U
                                      ON SPC.IdAsignadoA = U.IdUsuario
                              WHERE SPC.IdSolicitudPedido = P.IdSolicitudPedido
                                    AND SPC.Activo = 1
                              ORDER BY U.Nombre ASC
                              FOR XML PATH('')
                          ),
                          1,
                          1,
                          ''
                               )
               ) AS Asignados,
               Contrato = C.NumeroContrato
        FROM MM_Pedido AS P (NOLOCK)
            INNER JOIN dbo.MM_SolicitudPedido SP (NOLOCK)
                ON P.IdSolicitudPedido = SP.IdSolicitudPedido
            INNER JOIN MM_PedidoDetalle AS PD (NOLOCK)
                ON P.IdPedido = PD.IdPedido
            INNER JOIN MM_PeticionOferta AS PO (NOLOCK)
                ON P.IdPeticionOferta = PO.IdPeticionOferta
            INNER JOIN S_Proveedor AS PV (NOLOCK)
                ON P.IdSubcontratista = PV.IdProveedor
            INNER JOIN TA_Operacion AS O (NOLOCK)
                ON P.IdSolicitudPedido = O.IdDocumento
				AND	O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
				AND O.IdProveedor = @IdProveedor
            INNER JOIN TA_Prioridad AS PR (NOLOCK)
                ON O.IdPrioridad = PR.IdPrioridad
            INNER JOIN TA_Vencimiento AS V (NOLOCK)
                ON O.IdVigencia = V.IdVencimiento
			INNER JOIN TA_TipoOperacion AS TTO (NOLOCK)
                ON O.IdTipoOperacion = TTO.IdTipoOperacion
            INNER JOIN TA_Estatus AS E (NOLOCK)
                ON O.IdEstatusOperacion = E.IdEstatus
            INNER JOIN MM_HorasVigenciaPedido AS HV (NOLOCK)
                ON P.IdPedido = HV.IdPedido
            INNER JOIN PV_TipoMoneda AS TM (NOLOCK)
                ON P.IdMoneda = TM.IdMoneda
            INNER JOIN MM_Pedidos AS PG (NOLOCK)
                ON P.IdPedido = PG.IdIdentificador
                   AND PG.IdProveedorCliente = @IdProveedor
                   AND PG.IdTipoPedido IN ( 2, 4, 6 ) -->(Mer, AD, OT)
            INNER JOIN Adinco.dbo.CO_Contrato AS C (NOLOCK)
                ON SP.IdContrato = C.IdContrato
            LEFT JOIN dbo.MM_TipoPedido AS TP (NOLOCK)
                ON PG.IdTipoPedido = TP.IdTipoPedido
            LEFT JOIN #MM_SolicitudPedidoCompradorT SPC 
                ON P.IdSolicitudPedido = SPC.IdSolicitudPedido
			LEFT JOIN #WDEA_PurchasingDocumentsImportados PDI  (NOLOCK)
				ON  P.IdPedido = PDI.IdPedidoADINCO
        WHERE O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
              AND O.IdProveedor = @IdProveedor
              AND P.RecepcionServicio IS NULL --> LOS RECHAZADOS NO TIENE RECEPCIÓN ACEPTADA NI RECHAZADA
              AND E.IdEstatus = 3 --> ESTATUS RECHAZADO		
              AND P.Version = O.NoVersion --> LA VERSIÓN DE PEDIDO DEBE SER LA MISMA QUE LA DE LA OPERACIÓN
              AND ISNULL(P.IdEstatusEliminado, 0) <> 1 --> QUE NO ESTE ELIMINADO EL PEDIDO
              AND ISNULL(P.Cerrado, 0) = 0 --> PEDIDOS NO CERRADOS
              AND CASE
                      WHEN ISNULL(@EsAdministrador, 0) IN ( 0, 1 )
                           AND SPC.IdSolicitudPedido IS NOT NULL THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
                          1
                      WHEN ISNULL(@EsAdministrador, 0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
                          1
                      WHEN SP.IdUsuarioSolicitante = @IdUsuario THEN
                          1
                      ELSE
                          0 --> NO MOSTRAR NINGUNA 
                  END = 1
        GROUP BY P.IdPedido,
                 P.IdSolicitudPedido,
                 P.CreadoEl,
                 PV.RazonSocial,
                 PV.RegimenCapital,
                 P.RecepcionServicio,
                 E.Nombre,
                 P.Version,
                 TM.TipoMonedaCorto,
                 PG.IdPedido,
                 TP.TipoPedido,
                 TP.IdTipoPedido,
                 C.NumeroContrato,
				 PDI.MECANISMO_CONTRATACION
        ORDER BY PG.IdPedido DESC;

    END;

    IF @Filtro = 'EN_RECEPCION'
    BEGIN
        SELECT P.IdPedido,
               P.IdSolicitudPedido,
               P.FechaEnvioPedido AS FechaEnvioPedido,
               SUM(PD.Subtotal) AS TotalPedido,
               ISNULL(PV.RazonSocial, '') + ' ' + ISNULL(PV.RegimenCapital, '') AS Proveedor,
               'En Recepción' AS RecepcionServicio,
               E.Nombre,
               P.Version,
               TM.TipoMonedaCorto AS TipoMoneda,
               PG.IdPedido AS IdPedidoGeneral,
               CASE WHEN ISNULL(PDI.MECANISMO_CONTRATACION,'')='L' THEN 
				'Licitación'
			   ELSE 
				TP.TipoPedido
			   END AS TipoPedido,
               TP.IdTipoPedido,
               (
                   SELECT STUFF(
                          (
                              SELECT CAST(', ' AS VARCHAR(MAX)) + CONVERT(NVARCHAR(MAX), ISNULL(U.Nombre, ''))
                              FROM dbo.MM_SolicitudPedidoComprador SPC
                                  INNER JOIN dbo.S_Usuario U
                                      ON SPC.IdAsignadoA = U.IdUsuario
                              WHERE SPC.IdSolicitudPedido = P.IdSolicitudPedido
                                    AND SPC.Activo = 1
                              ORDER BY U.Nombre ASC
                              FOR XML PATH('')
                          ),
                          1,
                          1,
                          ''
                               )
               ) AS Asignados,
               Contrato = C.NumeroContrato
        FROM MM_Pedido AS P (NOLOCK)
            INNER JOIN dbo.MM_SolicitudPedido SP (NOLOCK)
                ON P.IdSolicitudPedido = SP.IdSolicitudPedido
            INNER JOIN MM_PedidoDetalle AS PD (NOLOCK)
                ON P.IdPedido = PD.IdPedido
            INNER JOIN MM_PeticionOferta AS PO (NOLOCK)
                ON P.IdPeticionOferta = PO.IdPeticionOferta
            INNER JOIN S_Proveedor AS PV (NOLOCK)
                ON P.IdSubcontratista = PV.IdProveedor
            INNER JOIN TA_Operacion AS O (NOLOCK)
                ON P.IdSolicitudPedido = O.IdDocumento
				AND	O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
				AND O.IdProveedor = @IdProveedor
            INNER JOIN TA_Prioridad AS PR (NOLOCK)
                ON O.IdPrioridad = PR.IdPrioridad
            INNER JOIN TA_Vencimiento AS V (NOLOCK)
                ON O.IdVigencia = V.IdVencimiento
            INNER JOIN TA_TipoOperacion AS TTO (NOLOCK)
                ON O.IdTipoOperacion = TTO.IdTipoOperacion
            INNER JOIN TA_Estatus AS E (NOLOCK)
                ON O.IdEstatusOperacion = E.IdEstatus
            INNER JOIN MM_HorasVigenciaPedido AS HV (NOLOCK)
                ON P.IdPedido = HV.IdPedido
            INNER JOIN PV_TipoMoneda AS TM (NOLOCK)
                ON P.IdMoneda = TM.IdMoneda
            INNER JOIN MM_Pedidos AS PG (NOLOCK)
                ON P.IdPedido = PG.IdIdentificador
                   AND @IdProveedor = PG.IdProveedorCliente
                   AND PG.IdTipoPedido IN ( 2, 4, 6 ) -->(Mer, AD, OT)
            INNER JOIN Adinco.dbo.CO_Contrato AS C (NOLOCK)
                ON SP.IdContrato = C.IdContrato
            LEFT JOIN dbo.MM_TipoPedido AS TP (NOLOCK)
                ON PG.IdTipoPedido = TP.IdTipoPedido
            LEFT JOIN #MM_SolicitudPedidoCompradorT SPC
                ON P.IdSolicitudPedido = SPC.IdSolicitudPedido			
			LEFT JOIN #WDEA_PurchasingDocumentsImportados PDI  (NOLOCK)
				ON  P.IdPedido = PDI.IdPedidoADINCO
        WHERE O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
              AND O.IdProveedor = @IdProveedor
              AND P.RecepcionServicio IS NULL
              AND E.IdEstatus = 2
              AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) <= 0
              AND HV.FechaVigencia IS NOT NULL
              AND P.Version = O.NoVersion --> LA VERSIÓN DE PEDIDO DEBE SER LA MISMA QUE LA DE LA OPERACIÓN
              AND ISNULL(P.IdEstatusEliminado, 0) <> 1 --> QUE NO ESTE ELIMINADO EL PEDIDO
              AND ISNULL(P.Cerrado, 0) = 0 --> PEDIDOS NO CERRADOS
              AND CASE
                      WHEN ISNULL(@EsAdministrador, 0) IN ( 0, 1 )
                           AND SPC.IdSolicitudPedido IS NOT NULL THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
                          1
                      WHEN ISNULL(@EsAdministrador, 0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
                          1
                      WHEN SP.IdUsuarioSolicitante = @IdUsuario THEN
                          1
                      ELSE
                          0 --> NO MOSTRAR NINGUNA 
                  END = 1
        GROUP BY P.IdPedido,
                 P.IdSolicitudPedido,
                 P.FechaEnvioPedido,
                 PV.RazonSocial,
                 PV.RegimenCapital,
                 P.RecepcionServicio,
                 E.Nombre,
                 P.Version,
                 TM.TipoMonedaCorto,
                 PG.IdPedido,
                 TP.TipoPedido,
                 TP.IdTipoPedido,
                 C.NumeroContrato,				 
				 PDI.MECANISMO_CONTRATACION
        ORDER BY PG.IdPedido DESC;

    END;

    IF @Filtro = 'EN_RECEPCION_ACEPTADA'
    BEGIN
        SELECT P.IdPedido,
               P.IdSolicitudPedido,
               P.FechaEnvioPedido AS FechaEnvioPedido,
               SUM(PD.Subtotal) AS TotalPedido,
               ISNULL(PV.RazonSocial, '') + ' ' + ISNULL(PV.RegimenCapital, '') AS Proveedor,
               CASE ISNULL(P.RecepcionServicio, 0)
                   WHEN 1 THEN
                       'Confirmado'
                   ELSE
                       'En Recepción'
               END AS RecepcionServicio,
               E.Nombre,
               P.Version,
               TM.TipoMonedaCorto AS TipoMoneda,
               PG.IdPedido AS IdPedidoGeneral,
               CASE WHEN ISNULL(PDI.MECANISMO_CONTRATACION,'')='L' THEN 
				'Licitación'
			   ELSE 
				TP.TipoPedido
			   END AS TipoPedido,
               TP.IdTipoPedido,
               (
                   SELECT STUFF(
                          (
                              SELECT CAST(', ' AS VARCHAR(MAX)) + CONVERT(NVARCHAR(MAX), ISNULL(U.Nombre, ''))
                              FROM dbo.MM_SolicitudPedidoComprador SPC
                                  INNER JOIN dbo.S_Usuario U
                                      ON SPC.IdAsignadoA = U.IdUsuario
                              WHERE SPC.IdSolicitudPedido = P.IdSolicitudPedido
                                    AND SPC.Activo = 1
                              ORDER BY U.Nombre ASC
                              FOR XML PATH('')
                          ),
                          1,
                          1,
                          ''
                               )
               ) AS Asignados,
               Contrato = C.NumeroContrato
        FROM MM_Pedido AS P (NOLOCK)
            INNER JOIN dbo.MM_SolicitudPedido SP (NOLOCK)
                ON P.IdSolicitudPedido = SP.IdSolicitudPedido
            INNER JOIN MM_PedidoDetalle AS PD (NOLOCK)
                ON P.IdPedido = PD.IdPedido
            INNER JOIN MM_PeticionOferta AS PO (NOLOCK)
                ON P.IdPeticionOferta = PO.IdPeticionOferta
            INNER JOIN S_Proveedor AS PV (NOLOCK)
                ON P.IdSubcontratista = PV.IdProveedor
            INNER JOIN TA_Operacion AS O (NOLOCK)
                ON P.IdSolicitudPedido = O.IdDocumento
				AND	O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
				AND O.IdProveedor = @IdProveedor
            INNER JOIN TA_Prioridad AS PR (NOLOCK)
                ON O.IdPrioridad = PR.IdPrioridad
            INNER JOIN TA_Vencimiento AS V (NOLOCK)
                ON O.IdVigencia = V.IdVencimiento
            INNER JOIN TA_TipoOperacion AS TTO (NOLOCK)
                ON O.IdTipoOperacion = TTO.IdTipoOperacion
            INNER JOIN TA_Estatus AS E (NOLOCK)
                ON O.IdEstatusOperacion = E.IdEstatus
            INNER JOIN MM_HorasVigenciaPedido AS HV (NOLOCK)
                ON P.IdPedido = HV.IdPedido 
            INNER JOIN PV_TipoMoneda AS TM (NOLOCK)
                ON P.IdMoneda = TM.IdMoneda
            INNER JOIN MM_Pedidos AS PG (NOLOCK)
                ON P.IdPedido = PG.IdIdentificador
                   AND PG.IdProveedorCliente = @IdProveedor
                   AND PG.IdTipoPedido IN ( 2, 4, 6 ) -->(Mer, AD, OT)
            INNER JOIN Adinco.dbo.CO_Contrato AS C (NOLOCK)
                ON SP.IdContrato = C.IdContrato
            LEFT JOIN dbo.MM_TipoPedido AS TP (NOLOCK)
                ON PG.IdTipoPedido = TP.IdTipoPedido
            LEFT JOIN #MM_SolicitudPedidoCompradorT SPC (NOLOCK)
                ON P.IdSolicitudPedido = SPC.IdSolicitudPedido
			LEFT JOIN #WDEA_PurchasingDocumentsImportados PDI  (NOLOCK)
				ON  P.IdPedido = PDI.IdPedidoADINCO
        WHERE O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
              AND O.IdProveedor = @IdProveedor
              AND P.RecepcionServicio = 1 --> RECEPCIÓN ACEPTADA
              AND E.IdEstatus = 2 --> ESTATUS APROBADO (TODOS LOS PEDIDOS RECEPCIONADOS DEBEN SER APROBADOS PRIMERO)
              AND HV.FechaVigencia IS NOT NULL --> DEBE HABER UNA FECHA DE VIGENCIA DE RECEPCIÓN
              AND P.Version = O.NoVersion --> LA VERSIÓN DE PEDIDO DEBE SER LA MISMA QUE LA DE LA OPERACIÓN
              AND ISNULL(P.IdEstatusEliminado, 0) <> 1 --> QUE NO ESTE ELIMINADO EL PEDIDO
              AND ISNULL(P.Cerrado, 0) = 0 --> PEDIDOS NO CERRADOS
              AND CASE
                      WHEN ISNULL(@EsAdministrador, 0) IN ( 0, 1 )
                           AND SPC.IdSolicitudPedido IS NOT NULL THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
                          1
                      WHEN ISNULL(@EsAdministrador, 0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
                          1
                      WHEN SP.IdUsuarioSolicitante = @IdUsuario THEN
                          1
                      ELSE
                          0 --> NO MOSTRAR NINGUNA 
                  END = 1
        GROUP BY P.IdPedido,
                 P.IdSolicitudPedido,
                P.FechaEnvioPedido,
                 PV.RazonSocial,
                 PV.RegimenCapital,
                 P.RecepcionServicio,
                 E.Nombre,
                 P.Version,
                 TM.TipoMonedaCorto,
                 PG.IdPedido,
                 TP.TipoPedido,
                 TP.IdTipoPedido,
                 C.NumeroContrato,
				 PDI.MECANISMO_CONTRATACION
        ORDER BY PG.IdPedido DESC;

    END;


    IF @Filtro = 'EN_RECEPCION_RECHAZADA'
    BEGIN
        SELECT P.IdPedido,
               P.IdSolicitudPedido,
               P.FechaEnvioPedido AS FechaEnvioPedido,
               SUM(PD.Subtotal) AS TotalPedido,
               ISNULL(PV.RazonSocial, '') + ' ' + ISNULL(PV.RegimenCapital, '') AS Proveedor,
               CASE ISNULL(P.RecepcionServicio, 0)
                   WHEN 1 THEN
                       'Confirmado'
                   ELSE
                       'En Recepción'
               END AS RecepcionServicio,
               E.Nombre,
               P.Version,
               TM.TipoMonedaCorto AS TipoMoneda,
               PG.IdPedido AS IdPedidoGeneral,
               CASE WHEN ISNULL(PDI.MECANISMO_CONTRATACION,'')='L' THEN 
				'Licitación'
			   ELSE 
				TP.TipoPedido
			   END AS TipoPedido,
               TP.IdTipoPedido,
               (
                   SELECT STUFF(
                          (
                              SELECT CAST(', ' AS VARCHAR(MAX)) + CONVERT(NVARCHAR(MAX), ISNULL(U.Nombre, ''))
                              FROM dbo.MM_SolicitudPedidoComprador SPC
                                  INNER JOIN dbo.S_Usuario U
                                      ON SPC.IdAsignadoA = U.IdUsuario
                              WHERE SPC.IdSolicitudPedido = P.IdSolicitudPedido
                                    AND SPC.Activo = 1
                              ORDER BY U.Nombre ASC
                              FOR XML PATH('')
                          ),
                          1,
                          1,
                          ''
                               )
               ) AS Asignados,
               Contrato = C.NumeroContrato
        FROM MM_Pedido AS P  (NOLOCK)
            INNER JOIN dbo.MM_SolicitudPedido SP  (NOLOCK)
                ON  P.IdSolicitudPedido=SP.IdSolicitudPedido
            INNER JOIN MM_PedidoDetalle AS PD  (NOLOCK)
                ON P.IdPedido=PD.IdPedido 
            INNER JOIN MM_PeticionOferta AS PO  (NOLOCK)
                ON P.IdPeticionOferta=PO.IdPeticionOferta 
            INNER JOIN S_Proveedor AS PV  (NOLOCK)
                ON P.IdSubcontratista=PV.IdProveedor
            INNER JOIN TA_Operacion AS O  (NOLOCK)
                ON P.IdSolicitudPedido=O.IdDocumento
				AND	O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
				AND O.IdProveedor = @IdProveedor
            INNER JOIN TA_Prioridad AS PR  (NOLOCK)
                ON O.IdPrioridad=PR.IdPrioridad
            INNER JOIN TA_Vencimiento AS V  (NOLOCK)
                ON O.IdVigencia=V.IdVencimiento
            INNER JOIN TA_TipoOperacion AS TTO (NOLOCK)
                ON O.IdTipoOperacion=TTO.IdTipoOperacion  
            INNER JOIN TA_Estatus AS E (NOLOCK)
                ON O.IdEstatusOperacion=E.IdEstatus 
            INNER JOIN MM_HorasVigenciaPedido AS HV (NOLOCK)
                ON P.IdPedido = HV.IdPedido 
            INNER JOIN PV_TipoMoneda AS TM (NOLOCK)
                ON P.IdMoneda=TM.IdMoneda
            INNER JOIN MM_Pedidos AS PG (NOLOCK)
                ON P.IdPedido = PG.IdIdentificador
                   AND PG.IdProveedorCliente = @IdProveedor
                   AND PG.IdTipoPedido IN ( 2, 4, 6 ) -->(Mer, AD, OT)
            INNER JOIN Adinco.dbo.CO_Contrato AS C (NOLOCK)
                ON SP.IdContrato = C.IdContrato
            LEFT JOIN dbo.MM_TipoPedido AS TP (NOLOCK)
                ON PG.IdTipoPedido=TP.IdTipoPedido
            LEFT JOIN #MM_SolicitudPedidoCompradorT SPC
                ON  P.IdSolicitudPedido=SPC.IdSolicitudPedido
			LEFT JOIN #WDEA_PurchasingDocumentsImportados PDI  (NOLOCK)
				ON  P.IdPedido = PDI.IdPedidoADINCO
        WHERE O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
              AND O.IdProveedor = @IdProveedor
              AND P.RecepcionServicio = 0 --> RECEPCIÓN RECHAZADA
              AND E.IdEstatus = 2 --> ESTATUS APROBADO /PARA ESTAR RECEPCIONADO DEBE ESTAR APROBADO 
AND HV.FechaVigencia IS NOT NULL --> DEBE HABER UNA FECHA LIMITE DE RECEPCIÓN
   AND P.Version = O.NoVersion --> LA VERSIÓN DE PEDIDO DEBE SER LA MISMA QUE LA DE LA OPERACIÓN
              AND ISNULL(P.IdEstatusEliminado, 0) <> 1 --> QUE NO ESTE ELIMINADO EL PEDIDO
              AND ISNULL(P.Cerrado, 0) = 0 --> PEDIDOS NO CERRADOS
              AND CASE
                      WHEN ISNULL(@EsAdministrador, 0) IN ( 0, 1 )
                           AND SPC.IdSolicitudPedido IS NOT NULL THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
                          1
                      WHEN ISNULL(@EsAdministrador, 0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
                          1
                      WHEN SP.IdUsuarioSolicitante = @IdUsuario THEN
                          1
                      ELSE
                          0 --> NO MOSTRAR NINGUNA 
                  END = 1
        GROUP BY P.IdPedido,
                 P.IdSolicitudPedido,
                 P.FechaEnvioPedido,
                 PV.RazonSocial,
                 PV.RegimenCapital,
                 P.RecepcionServicio,
                 E.Nombre,
                 P.Version,
                 TM.TipoMonedaCorto,
                 PG.IdPedido,
                 TP.TipoPedido,
                 TP.IdTipoPedido,
                 C.NumeroContrato,
				 PDI.MECANISMO_CONTRATACION
        ORDER BY PG.IdPedido DESC;

    END;

    IF @Filtro = 'EN_RECEPCION_VENCIDA'
    BEGIN
        SELECT P.IdPedido,
               P.IdSolicitudPedido,
               P.FechaEnvioPedido AS FechaEnvioPedido,
               SUM(PD.Subtotal) AS TotalPedido,
               ISNULL(PV.RazonSocial, '') + ' ' + ISNULL(PV.RegimenCapital, '') AS Proveedor,
               'Confirmación Vencida' RecepcionServicio,
               E.Nombre,
               P.Version,
               TM.TipoMonedaCorto AS TipoMoneda,
               PG.IdPedido AS IdPedidoGeneral,
               CASE WHEN ISNULL(PDI.MECANISMO_CONTRATACION,'')='L' THEN 
				'Licitación'
			   ELSE 
				TP.TipoPedido
			   END AS TipoPedido,
               TP.IdTipoPedido,
               (
                   SELECT STUFF(
                          (
                              SELECT CAST(', ' AS VARCHAR(MAX)) + CONVERT(NVARCHAR(MAX), ISNULL(U.Nombre, ''))
                              FROM dbo.MM_SolicitudPedidoComprador SPC
                                  INNER JOIN dbo.S_Usuario U
                                      ON SPC.IdAsignadoA = U.IdUsuario
                              WHERE SPC.IdSolicitudPedido = P.IdSolicitudPedido
                                    AND SPC.Activo = 1
                              ORDER BY U.Nombre ASC
                              FOR XML PATH('')
                          ),
                          1,
                          1,
                          ''
                               )
               ) AS Asignados,
               Contrato = C.NumeroContrato
        FROM MM_Pedido AS P (NOLOCK)
            INNER JOIN dbo.MM_SolicitudPedido SP (NOLOCK)
                ON P.IdSolicitudPedido=SP.IdSolicitudPedido
            INNER JOIN MM_PedidoDetalle AS PD (NOLOCK)
                ON P.IdPedido=PD.IdPedido
            INNER JOIN MM_PeticionOferta AS PO (NOLOCK)
                ON P.IdPeticionOferta= PO.IdPeticionOferta
            INNER JOIN S_Proveedor AS PV (NOLOCK)
                ON P.IdSubcontratista=PV.IdProveedor
            INNER JOIN TA_Operacion AS O (NOLOCK)
                ON P.IdSolicitudPedido=O.IdDocumento
				AND	O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
				AND O.IdProveedor = @IdProveedor
            INNER JOIN TA_Prioridad AS PR (NOLOCK)
                ON O.IdPrioridad=PR.IdPrioridad
            INNER JOIN TA_Vencimiento AS V (NOLOCK)
                ON O.IdVigencia= V.IdVencimiento 
            INNER JOIN TA_TipoOperacion AS TTO (NOLOCK)
                ON O.IdTipoOperacion=TTO.IdTipoOperacion 
            INNER JOIN TA_Estatus AS E (NOLOCK)
                ON O.IdEstatusOperacion=E.IdEstatus 
            INNER JOIN MM_HorasVigenciaPedido AS HV (NOLOCK)
                ON P.IdPedido = HV.IdPedido
            INNER JOIN PV_TipoMoneda AS TM (NOLOCK)
                ON P.IdMoneda=TM.IdMoneda 
            INNER JOIN MM_Pedidos AS PG (NOLOCK)
                ON P.IdPedido = PG.IdIdentificador
                   AND PG.IdProveedorCliente = @IdProveedor
                   AND PG.IdTipoPedido IN ( 2, 4, 6 ) -->(Mer, AD, OT)
            INNER JOIN Adinco.dbo.CO_Contrato AS C (NOLOCK)
                ON SP.IdContrato = C.IdContrato
            LEFT JOIN dbo.MM_TipoPedido AS TP (NOLOCK)
                ON PG.IdTipoPedido=TP.IdTipoPedido 
            LEFT JOIN #MM_SolicitudPedidoCompradorT SPC
                ON P.IdSolicitudPedido=SPC.IdSolicitudPedido 
			LEFT JOIN #WDEA_PurchasingDocumentsImportados PDI  (NOLOCK)
				ON  P.IdPedido = PDI.IdPedidoADINCO
        WHERE O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
              AND O.IdProveedor = @IdProveedor
              AND P.RecepcionServicio IS NULL --> NO SE HA REALIZADO RECEPCIÓN
              AND E.IdEstatus = 2 --> EL PEDIDO DEBE ESTAR APROBADO
              AND HV.FechaVigencia IS NOT NULL --> SE DEBE TENER UNA FECHA LIMITE DE RECEPCIÓN
              AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) >= 0 --> SI LA FECHA DE RECEPCIÓN YA PASO 
              AND P.Version = O.NoVersion --> LA VERSIÓN DE PEDIDO DEBE SER LA MISMA QUE LA DE LA OPERACIÓN
              AND ISNULL(P.IdEstatusEliminado, 0) <> 1 --> QUE NO ESTE ELIMINADO EL PEDIDO
              AND ISNULL(P.Cerrado, 0) = 0 --> PEDIDOS NO CERRADOS
              AND CASE
                      WHEN ISNULL(@EsAdministrador, 0) IN ( 0, 1 )
                           AND SPC.IdSolicitudPedido IS NOT NULL THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
                          1
                      WHEN ISNULL(@EsAdministrador, 0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
                          1
                      WHEN SP.IdUsuarioSolicitante = @IdUsuario THEN
                          1
                      ELSE
                          0 --> NO MOSTRAR NINGUNA 
                  END = 1
        GROUP BY P.IdPedido,
                 P.IdSolicitudPedido,
                 P.FechaEnvioPedido,
                 PV.RazonSocial,
                 PV.RegimenCapital,
                 P.RecepcionServicio,
                 E.Nombre,
                 P.Version,
                 TM.TipoMonedaCorto,
                 PG.IdPedido,
                 TP.TipoPedido,
                 TP.IdTipoPedido,
                 C.NumeroContrato,
				 PDI.MECANISMO_CONTRATACION
        ORDER BY PG.IdPedido DESC;
    END;

    IF @Filtro = 'CERRADOS'
    BEGIN
        SELECT P.IdPedido,
               P.IdSolicitudPedido,
               P.CreadoEl AS CreadoEl,
               P.FechaEnvioPedido AS FechaEnvioPedido,
               SUM(PD.Subtotal) AS TotalPedido,
               ISNULL(PV.RazonSocial, '') + ' ' + ISNULL(PV.RegimenCapital, '') AS Proveedor,
               CASE
                   WHEN P.RecepcionServicio = 1 THEN
                       'Confirmación Aceptada'
                   WHEN P.RecepcionServicio = 0 THEN
                       'Confirmación Rechazada'
                   WHEN P.RecepcionServicio IS NULL
                        AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) >= 0
                        AND O.IdEstatusOperacion = 2 THEN
                       'Confirmación Vencida '
                   WHEN P.RecepcionServicio IS NULL
                        AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) <= 0
                        AND O.IdEstatusOperacion = 2 THEN
                       'En Confirmación'
                   ELSE
                       'Confirmación No Iniciada '
               END AS RecepcionServicio,
               E.Nombre,
               CAST(P.Version AS NVARCHAR(200)) AS Version,
               TM.TipoMonedaCorto AS TipoMoneda,
               PG.IdPedido AS IdPedidoGeneral,
               CASE WHEN ISNULL(PDI.MECANISMO_CONTRATACION,'')='L' THEN 
				'Licitación'
			   ELSE 
				TP.TipoPedido
			   END AS TipoPedido,
               TP.IdTipoPedido,
               (
                   SELECT STUFF(
                          (
                              SELECT CAST(', ' AS VARCHAR(MAX)) + CONVERT(NVARCHAR(MAX), ISNULL(U.Nombre, ''))
                       FROM dbo.MM_SolicitudPedidoComprador SPC
                    INNER JOIN dbo.S_Usuario U
                                      ON SPC.IdAsignadoA = U.IdUsuario
                              WHERE SPC.IdSolicitudPedido = P.IdSolicitudPedido
                                    AND SPC.Activo = 1
                              ORDER BY U.Nombre ASC
                              FOR XML PATH('')
                          ),
                          1,
                          1,
                          ''
                               )
               ) AS Asignados,
               Contrato = C.NumeroContrato
        FROM MM_Pedido AS P (NOLOCK)
            INNER JOIN dbo.MM_SolicitudPedido SP (NOLOCK)
                ON P.IdSolicitudPedido=SP.IdSolicitudPedido 
            INNER JOIN MM_PedidoDetalle AS PD (NOLOCK)
                ON P.IdPedido=PD.IdPedido 
            INNER JOIN MM_PeticionOferta AS PO (NOLOCK)
                ON  P.IdPeticionOferta=PO.IdPeticionOferta
            INNER JOIN S_Proveedor AS PV (NOLOCK)
                ON P.IdSubcontratista=PV.IdProveedor 
            INNER JOIN TA_Operacion AS O (NOLOCK)
                ON P.IdSolicitudPedido=O.IdDocumento
				AND	O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
				AND O.IdProveedor = @IdProveedor
            INNER JOIN TA_Prioridad AS PR (NOLOCK)
                ON O.IdPrioridad=PR.IdPrioridad
            INNER JOIN TA_Vencimiento AS V (NOLOCK)
                ON O.IdVigencia=V.IdVencimiento 
            INNER JOIN TA_TipoOperacion AS TTO (NOLOCK)
                ON  O.IdTipoOperacion=TTO.IdTipoOperacion
            INNER JOIN TA_Estatus AS E (NOLOCK)
                ON O.IdEstatusOperacion=E.IdEstatus 
            INNER JOIN MM_HorasVigenciaPedido AS HV (NOLOCK)
                ON  P.IdPedido = HV.IdPedido
            INNER JOIN PV_TipoMoneda AS TM (NOLOCK)
                ON P.IdMoneda=TM.IdMoneda 
            INNER JOIN MM_Pedidos AS PG (NOLOCK)
                ON P.IdPedido = PG.IdIdentificador
                   AND PG.IdProveedorCliente = @IdProveedor
                   AND PG.IdTipoPedido IN ( 2, 4, 6 ) -->(Mer, AD, OT)
            INNER JOIN Adinco.dbo.CO_Contrato AS C (NOLOCK)
                ON SP.IdContrato = C.IdContrato
            LEFT JOIN dbo.MM_TipoPedido AS TP (NOLOCK)
                ON PG.IdTipoPedido=TP.IdTipoPedido
            LEFT JOIN #MM_SolicitudPedidoCompradorT SPC
                ON P.IdSolicitudPedido=SPC.IdSolicitudPedido 
			LEFT JOIN #WDEA_PurchasingDocumentsImportados PDI  (NOLOCK)
				ON  P.IdPedido = PDI.IdPedidoADINCO
        WHERE O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
              AND O.IdProveedor = @IdProveedor
              AND P.Version = O.NoVersion --> LA VERSIÓN DE PEDIDO DEBE SER LA MISMA QUE LA DE LA OPERACIÓN
              AND ISNULL(P.IdEstatusEliminado, 0) <> 1 --> QUE NO ESTE ELIMINADO EL PEDIDO
              AND ISNULL(P.Cerrado, 0) = 1 --> PEDIDOS CERRADOS
              AND CASE
                      WHEN ISNULL(@EsAdministrador, 0) IN ( 0, 1 )
                           AND SPC.IdSolicitudPedido IS NOT NULL THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
                          1
                      WHEN ISNULL(@EsAdministrador, 0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
                          1
                      WHEN SP.IdUsuarioSolicitante = @IdUsuario THEN
                          1
                      ELSE
                          0 --> NO MOSTRAR NINGUNA 
                  END = 1
        GROUP BY P.IdPedido,
                 P.IdSolicitudPedido,
                 P.FechaEnvioPedido,
                 PV.RazonSocial,
                 PV.RegimenCapital,
                 P.RecepcionServicio,
                 E.Nombre,
                 P.Version,
                 TM.TipoMonedaCorto,
                 HV.FechaVigencia,
                 O.IdEstatusOperacion,
                 P.CreadoEl,
                 PG.IdPedido,
                 TP.TipoPedido,
                 TP.IdTipoPedido,
                 P.IdEstatusEliminado,
                 C.NumeroContrato,
				 PDI.MECANISMO_CONTRATACION
        ORDER BY PG.IdPedido DESC;

    END;

    IF @Filtro = 'TODOS'
    BEGIN
        SELECT P.IdPedido,
               P.IdSolicitudPedido,
               P.CreadoEl AS CreadoEl,
               P.FechaEnvioPedido AS FechaEnvioPedido,
               SUM(PD.Subtotal) AS TotalPedido,
               ISNULL(PV.RazonSocial, '') + ' ' + ISNULL(PV.RegimenCapital, '') AS Proveedor,
               CASE
                   WHEN P.RecepcionServicio = 1 THEN
                       'Confirmación Aceptada'
                   WHEN P.RecepcionServicio = 0 THEN
                       'Confirmación Rechazada'
                   WHEN P.RecepcionServicio IS NULL
                        AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) >= 0
                        AND O.IdEstatusOperacion = 2 THEN
                       'Confirmación Vencida '
                   WHEN P.RecepcionServicio IS NULL
                        AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) <= 0
                        AND O.IdEstatusOperacion = 2 THEN
                       'En Confirmación'
                   ELSE
                       'Confirmación No Iniciada '
               END AS RecepcionServicio,
               E.Nombre,
               CAST(P.Version AS NVARCHAR(200)) AS Version,
               TM.TipoMonedaCorto AS TipoMoneda,
               PG.IdPedido AS IdPedidoGeneral,
               CASE WHEN ISNULL(PDI.MECANISMO_CONTRATACION,'')='L' THEN 
				'Licitación'
			   ELSE 
				TP.TipoPedido
			   END AS TipoPedido,
               TP.IdTipoPedido,
               (
                   SELECT STUFF(
                          (
                              SELECT CAST(', ' AS VARCHAR(MAX)) + CONVERT(NVARCHAR(MAX), ISNULL(U.Nombre, ''))
                              FROM dbo.MM_SolicitudPedidoComprador SPC
                                  INNER JOIN dbo.S_Usuario U
                                      ON SPC.IdAsignadoA = U.IdUsuario
                              WHERE SPC.IdSolicitudPedido = P.IdSolicitudPedido
                                    AND SPC.Activo = 1
                              ORDER BY U.Nombre ASC
                              FOR XML PATH('')
                          ),
                          1,
                          1,
                          ''
                               )
               ) AS Asignados,
               APO.ID_PO,
               Contrato = C.NumeroContrato
        FROM MM_Pedido AS P (NOLOCK)
            INNER JOIN dbo.MM_SolicitudPedido SP (NOLOCK)
                ON P.IdSolicitudPedido=SP.IdSolicitudPedido
            INNER JOIN MM_PedidoDetalle AS PD (NOLOCK)
                ON P.IdPedido=PD.IdPedido 
            INNER JOIN MM_PeticionOferta AS PO (NOLOCK)
                ON P.IdPeticionOferta=PO.IdPeticionOferta
            INNER JOIN S_Proveedor AS PV (NOLOCK)
                ON P.IdSubcontratista=PV.IdProveedor 
            INNER JOIN TA_Operacion AS O (NOLOCK)
                ON  P.IdSolicitudPedido=O.IdDocumento
				AND	O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
				AND O.IdProveedor = @IdProveedor
            INNER JOIN TA_Prioridad AS PR (NOLOCK)
                ON  O.IdPrioridad=PR.IdPrioridad
            INNER JOIN TA_Vencimiento AS V (NOLOCK)
                ON  O.IdVigencia=V.IdVencimiento
            INNER JOIN TA_TipoOperacion AS TTO (NOLOCK)
                ON O.IdTipoOperacion=TTO.IdTipoOperacion 
            INNER JOIN TA_Estatus AS E (NOLOCK)
                ON O.IdEstatusOperacion=E.IdEstatus 
            INNER JOIN MM_HorasVigenciaPedido AS HV (NOLOCK)
                ON P.IdPedido = HV.IdPedido
            INNER JOIN PV_TipoMoneda AS TM (NOLOCK)
                ON  P.IdMoneda=TM.IdMoneda
            INNER JOIN MM_Pedidos AS PG (NOLOCK)
                ON P.IdPedido = PG.IdIdentificador
                   AND PG.IdProveedorCliente = @IdProveedor
                   AND PG.IdTipoPedido IN ( 2, 4, 6 )
            INNER JOIN Adinco.dbo.CO_Contrato AS C (NOLOCK)
                ON SP.IdContrato = C.IdContrato
            LEFT JOIN dbo.MM_TipoPedido AS TP (NOLOCK)
                ON PG.IdTipoPedido=TP.IdTipoPedido 
            LEFT JOIN #MM_SolicitudPedidoCompradorT SPC
                ON P.IdSolicitudPedido=SPC.IdSolicitudPedido 
            LEFT JOIN dbo.DEA_Relacion_PR_PO RPO (NOLOCK)
                ON P.IdPedido=RPO.IdPedido 
            LEFT JOIN dbo.DEA_AdjuntoPO APO (NOLOCK)
                ON RPO.IdAdjuntoPO=APO.IdAdjuntoPO
			LEFT JOIN #WDEA_PurchasingDocumentsImportados PDI
				ON  P.IdPedido = PDI.IdPedidoADINCO
        WHERE O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
              AND O.IdProveedor = @IdProveedor
              AND P.Version = O.NoVersion --> LA VERSIÓN DE PEDIDO DEBE SER LA MISMA QUE LA DE LA OPERACIÓN
              AND ISNULL(P.IdEstatusEliminado, 0) <> 1 --> QUE NO ESTE ELIMINADO EL PEDIDO
              AND CASE
                      WHEN ISNULL(@EsAdministrador, 0) IN ( 0, 1 )
                           AND SPC.IdSolicitudPedido IS NOT NULL THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
                          1
                      WHEN ISNULL(@EsAdministrador, 0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
                          1
                      WHEN SP.IdUsuarioSolicitante = @IdUsuario THEN
                          1
                      ELSE
                          0 --> NO MOSTRAR NINGUNA 
                  END = 1
        GROUP BY P.IdPedido,
                 P.IdSolicitudPedido,
                 P.FechaEnvioPedido,
                 PV.RazonSocial,
                 PV.RegimenCapital,
                 P.RecepcionServicio,
                 E.Nombre,
                 P.Version,
                 TM.TipoMonedaCorto,
                 HV.FechaVigencia,
                 O.IdEstatusOperacion,
                 P.CreadoEl,
                 PG.IdPedido,
                 TP.TipoPedido,
                 TP.IdTipoPedido,
                 P.IdEstatusEliminado,
                 APO.ID_PO,
                 C.NumeroContrato,
				 PDI.MECANISMO_CONTRATACION
        ORDER BY PG.IdPedido DESC;

    END;
END