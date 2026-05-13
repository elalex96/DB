-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar Solicitudes de Oferta 
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 26/01/2018
-- Description:	se agrega el filtro por tipo de adjudicacion 1 -Mercadeo
-- =============================================
-- Author: Daniel AC
-- Update date: 20/11/2019
-- Description: Se agregaron filtros para que el usuario actual solo puede ver las ofertas que le fueron asingadas o si es usuario admini o adminin de compras puede ver todas
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 09-01-2020
-- Description:	cambio en los estatus de cotizacion
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 13-01-2020
-- Description:	validacion de compradores asignados
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 15-01-2020
-- Description:	agregado de los estatus de ofertas
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 30-03-2020
-- Description:	agregado de los numeros de PR para DEA
-- =============================================
create PROCEDURE [dbo].[SP_MM_ConsultaOfertas] --420,3,0
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,
    @Estatus INT,
    @IdContrato INT,
    @IdUsuario INT,
    @FechaRegistro DATETIME
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    -- Insert statements for procedure here
	DECLARE @EsAdministradorCompras BIT =0
	DECLARE @EsTipoAdministrador BIT = 0
	DECLARE @EsAdministrador BIT =0

	--CONSULTAR SI EL USUARIO ACTUAL ES ADMINISTRADOR DE COMPRAS
	SELECT  @EsAdministradorCompras=Activo
	FROM dbo.CC_AdministradorCompras 
	WHERE IdUsuario=@IdUsuario 
	AND Activo=1
	AND IdProveedor=@IdProveedor
		
	--CONSULTAR SI EL USUARIO ACTUAL ES USUARIO DE TIPO ADMINISTRADOR 
	SELECT @EsTipoAdministrador=CASE WHEN COUNT(1)> 0 THEN 1 ELSE 0 END
	FROM dbo.S_Usuario U 
	WHERE U.IdTipoUsuario IN (3,4,6,7,8)   --> CTES Administrador,Ventas,Director General,Root  
	AND U.IdUsuario=@IdUsuario

	--SI CUMPLE ALGUNO DE ESTOS PARAMETROS ES UN ADMINISTRADOR Y PUEDE VER TODAS LAS PETICIONES DE SOL OFERTA
	-- SI NO SOLO PODRÁ VER LAS SOL OFERTA DONDE FUE ASIGNADO
	IF @EsTipoAdministrador=1 OR @EsAdministradorCompras =1
	BEGIN
        SET @EsAdministrador =1
	END 

	CREATE TABLE #CompradorAsignado(IdSolicitudPedido INT, Asignado BIT)
	--SE INCERTAN LAS SOLPED ASIGANADAS A ESE COMPRADOR
	INSERT INTO #CompradorAsignado
	SELECT
		SPCA.IdSolicitudPedido,
		1
	FROM dbo.MM_SolicitudPedidoComprador AS SPCA
	WHERE SPCA.IdAsignadoA = @IdUsuario
		AND SPCA.Activo = 1
	GROUP BY SPCA.IdSolicitudPedido

	--SI ES ADMINISTRADOR SE MUESTRAN TODAS
	IF @EsAdministrador = 1
	BEGIN
	    INSERT INTO #CompradorAsignado
		SELECT
			SPCA.IdSolicitudPedido,
			1
		FROM dbo.MM_SolicitudPedidoComprador AS SPCA
		WHERE SPCA.IdSolicitudPedido NOT IN (SELECT 
												IdSolicitudPedido 
											FROM #CompradorAsignado)
		GROUP BY SPCA.IdSolicitudPedido
	END

	CREATE TABLE #DISPONIBILIDADOFERTASDETALLE
	(
		IdSolicitudPedido int,
		OfertaVencida INT
	)

	INSERT INTO #DISPONIBILIDADOFERTASDETALLE
	SELECT
		SP.IdSolicitudPedido,
		SUM(CASE 
			WHEN POD.FechaVigencia < GETDATE() THEN 1
			WHEN POD.FechaVigencia > GETDATE() THEN 0
		END)
	FROM dbo.MM_PeticionOfertaDetalle AS POD
		LEFT JOIN dbo.MM_PeticionOferta AS PO ON PO.IdPeticionOferta = POD.IdPeticionOferta
		LEFT JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
		LEFT JOIN dbo.MM_PedidoDetalle AS PD ON PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
	WHERE SP.IdProveedor = @IdProveedor
		AND POD.Cotizado = 1
		AND POD.FechaVigencia IS NOT NULL
		GROUP BY
                 SP.IdSolicitudPedido
		ORDER BY SP.IdSolicitudPedido DESC;


    IF @Estatus = 1 ---EN COTIZACION

    BEGIN


        SELECT SP.IdSolicitudPedido,
               TSP.TipoSolicitudPedido,
               ISNULL('PR N.' + PRDEA.ID_PR + ' - ','') +  O.Descripcion AS Descripcion,
               O.FechaRegistro,
               O.FechaFinalizacion AS FechaFinOferta,
               CAST(SUM(   CASE
                               WHEN PO.NoCotizar = 1 THEN
                                   1
                               ELSE
                                   CASE
                                       WHEN PO.Cotizado = 1 THEN
                                           1
                                       ELSE
                                           0
                                   END
                           END
                       ) AS NVARCHAR(MAX)) + '/' + CAST(COUNT(PO.IdPeticionOferta) AS NVARCHAR(MAX)) AS Nombre,
					(SELECT	STUFF ((SELECT CAST(', ' AS VARCHAR(MAX)) + CONVERT ( NVARCHAR(MAX), ISNULL(U.Nombre,'') )
					FROM dbo.MM_SolicitudPedidoComprador SPC 	
					INNER JOIN dbo.S_Usuario U ON U.IdUsuario=SPC.IdAsignadoA	
					WHERE 		
					SPC.IdSolicitudPedido = SP.IdSolicitudPedido	
					AND SPC.Activo=1
					ORDER BY U.Nombre ASC
					FOR XML PATH ( '' )), 1, 1, '' )) AS Asignados,
					Contrato						=	c.NumeroContrato
		FROM		MM_SolicitudPedido				AS	SP
		INNER JOIN	MM_TipoSolicitudPedido			AS	TSP
		ON			TSP.IdTipoSolicitudPedido		=	SP.IdTipoSolicitudPedido
		INNER JOIN	TA_Operacion					AS	O
		ON			O.IdDocumento					=	SP.IdSolicitudPedido
		AND			O.IdTipoOperacion				=	6
		LEFT JOIN	TA_Vencimiento					AS	V
		ON			V.IdVencimiento					=	O.IdVigencia
		INNER JOIN	TA_Estatus						AS	E
		ON			E.IdEstatus						=	O.IdEstatusOperacion
		LEFT JOIN	MM_PeticionOferta				AS	PO
		ON			PO.IdSolicitudPedido			=	SP.IdSolicitudPedido
		LEFT JOIN	dbo.MM_SolicitudPedidoComprador SPC 
		ON			SPC.IdSolicitudPedido			=	SP.IdSolicitudPedido	
		LEFT JOIN	dbo.DEA_AdjuntoPR				AS	PRDEA
		ON			PRDEA.IdSolicitudPedido			=	SP.IdSolicitudPedido
		inner JOIN	Adinco.dbo.CO_Contrato			AS	C 
		ON			SP.IdContrato					=	C.IdContrato
        WHERE SP.IdProveedor = @IdProveedor
              AND (DATEDIFF(MINUTE, O.FechaFinalizacion, GETDATE()) <= 0)
              AND SP.IdTipoProceso = 2 -- Mercadeo
			  AND ISNULL(O.IdEstatusEliminado,0)<>1 --> DIFERENTE DE ESTATUS ELIMINADO
			  AND CASE WHEN ISNULL(@EsAdministrador,0) IN (0,1) AND  SPC.IdSolicitudPedidoComprador IS NOT NULL AND SPC.IdAsignadoA=@IdUsuario AND SPC.Activo=1 THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
					1
			  WHEN  ISNULL(@EsAdministrador,0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
					1 
			   ELSE 
					0  --> NO MOSTRAR NINGUNA 
			END =1
        GROUP BY SP.IdSolicitudPedido,
                 TSP.TipoSolicitudPedido,
                 O.Descripcion,
                 O.FechaRegistro,
                 O.FechaFinalizacion,
				 PRDEA.ID_PR,
				 c.NumeroContrato
        ORDER BY SP.IdSolicitudPedido DESC

    END

    IF @ESTATUS = 2 --- COTIZACION FINALIZADA
    BEGIN

        SELECT SP.IdSolicitudPedido,
               TSP.TipoSolicitudPedido,
               ISNULL('PR N.' + PRDEA.ID_PR + ' - ','') +  O.Descripcion AS Descripcion,
               O.FechaRegistro,
               O.FechaFinalizacion AS FechaFinOferta,
               CAST(SUM(   CASE
                               WHEN PO.NoCotizar = 1 THEN
                                   1
                               ELSE
                                   CASE
                                       WHEN PO.Cotizado = 1 THEN
                                           1
                                       ELSE
                                           0
                                   END
                           END
                       ) AS NVARCHAR(MAX)) + '/' + CAST(COUNT(PO.IdPeticionOferta) AS NVARCHAR(MAX)) AS Nombre,
					   (SELECT	STUFF ((SELECT CAST(', ' AS VARCHAR(MAX)) + CONVERT ( NVARCHAR(MAX), ISNULL(U.Nombre,'') )
					FROM dbo.MM_SolicitudPedidoComprador SPC 	
					INNER JOIN dbo.S_Usuario U ON U.IdUsuario=SPC.IdAsignadoA	
					WHERE 		
					SPC.IdSolicitudPedido = SP.IdSolicitudPedido	
					AND SPC.Activo=1
					ORDER BY U.Nombre ASC
					FOR XML PATH ( '' )), 1, 1, '' )) AS Asignados,
					Contrato = c.NumeroContrato
        FROM MM_SolicitudPedido AS SP
            INNER JOIN MM_TipoSolicitudPedido AS TSP
                ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
            INNER JOIN TA_Operacion AS O
                ON O.IdDocumento = SP.IdSolicitudPedido
                   AND O.IdTipoOperacion = 6
            LEFT JOIN TA_Vencimiento AS V
                ON V.IdVencimiento = O.IdVigencia
            INNER JOIN TA_Estatus AS E
                ON E.IdEstatus = O.IdEstatusOperacion
            LEFT JOIN MM_PeticionOferta AS PO
                ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
			LEFT JOIN dbo.MM_SolicitudPedidoComprador SPC 
					ON SPC.IdSolicitudPedido = SP.IdSolicitudPedido	
			LEFT JOIN dbo.DEA_AdjuntoPR AS PRDEA
				ON PRDEA.IdSolicitudPedido = SP.IdSolicitudPedido
			inner JOIN	Adinco.dbo.CO_Contrato			AS	C 
			ON			SP.IdContrato					=	C.IdContrato
        WHERE SP.IdProveedor = @IdProveedor
              AND (DATEDIFF(MINUTE, O.FechaFinalizacion, GETDATE()) > 0)
              AND SP.IdTipoProceso = 2 -- Mercadeo
			   AND ISNULL(O.IdEstatusEliminado,0)<>1 --> DIFERENTE DE ESTATUS ELIMINADO
			   AND CASE WHEN ISNULL(@EsAdministrador,0) IN (0,1) AND  SPC.IdSolicitudPedidoComprador IS NOT NULL AND SPC.IdAsignadoA=@IdUsuario AND SPC.Activo=1 THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
					1
			  WHEN  ISNULL(@EsAdministrador,0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
					1 
			   ELSE 
					0  --> NO MOSTRAR NINGUNA 
			END =1
        GROUP BY SP.IdSolicitudPedido,
                 TSP.TipoSolicitudPedido,
                 O.Descripcion,
                 O.FechaRegistro,
                 O.FechaFinalizacion,
				 PRDEA.ID_PR,
				 c.NumeroContrato
        ORDER BY SP.IdSolicitudPedido DESC

    END

    IF @ESTATUS = 3 --- COTIZACION TODAS
    BEGIN

        SELECT SP.IdSolicitudPedido,
               TSP.TipoSolicitudPedido,
               ISNULL('PR N.' + PRDEA.ID_PR + ' - ','') +  O.Descripcion AS Descripcion,
               O.FechaRegistro,
               O.FechaFinalizacion AS FechaFinOferta,
               CAST(SUM(   CASE
                               WHEN PO.NoCotizar = 1 THEN
                                   1
                               ELSE
                                   CASE
                                       WHEN PO.Cotizado = 1 THEN
                                           1
                                       ELSE
                                           0
                                   END
                           END
                       ) AS NVARCHAR(MAX)) + '/' + CAST(COUNT(PO.IdPeticionOferta) AS NVARCHAR(MAX)) AS Nombre,
               (CASE 
				   WHEN (DATEDIFF(MINUTE, O.FechaFinalizacion, GETDATE()) < 0)  THEN
                       'EN COTIZACIÓN'
				   WHEN DATEDIFF(MINUTE, O.FechaFinalizacion, GETDATE()) > 0 AND (SELECT COUNT(PID.IdPedido) 
																					FROM dbo.MM_Pedido AS PID
																					WHERE PID.IdSolicitudPedido = SP.IdSolicitudPedido) >= 1 THEN
						'COTIZACIÓN CON OC ADJUDICADA'  
				   WHEN DATEDIFF(MINUTE, O.FechaFinalizacion, GETDATE()) > 0 AND (SUM(CASE 
																						WHEN PO.NoCotizar = 1 THEN 1 
																						ELSE 
																							CASE WHEN PO.Cotizado = 1 THEN 1 
																							ELSE 0 
																							END
																						END)) >= 1 THEN
						'COTIZACIÓN FINALIZADA'
				   WHEN DATEDIFF(MINUTE, O.FechaFinalizacion, GETDATE()) > 0 AND (SUM(CASE 
																						WHEN PO.NoCotizar = 1 THEN 1 
																						ELSE 
																							CASE WHEN PO.Cotizado = 1 THEN 1 
																							ELSE 0 
																							END
																						END)) <= 1 THEN
						'FINALIZADA PROVEDOR NO COTIZO'
               END) + 
			   (CASE
				WHEN DO.OfertaVencida > 0 THEN ' / ALGUNAS COTIZACIONES VENCIDAS'
				WHEN DO.OfertaVencida = 0 THEN ' / OFERTA(S) DE PROVEEDOR VIGENTE'
				ELSE ' '
			   END) AS EstatusCotizacion,
			   O.IdEstatusEliminado,
			   (SELECT	STUFF ((SELECT CAST(', ' AS VARCHAR(MAX)) + CONVERT ( NVARCHAR(MAX), ISNULL(U.Nombre,'') )
					FROM dbo.MM_SolicitudPedidoComprador SPC 	
					INNER JOIN dbo.S_Usuario U ON U.IdUsuario=SPC.IdAsignadoA	
					WHERE 		
					SPC.IdSolicitudPedido = SP.IdSolicitudPedido	
					AND SPC.Activo=1
					ORDER BY U.Nombre ASC
					FOR XML PATH ( '' )), 1, 1, '' )) AS Asignados,
					Contrato = c.NumeroContrato
        FROM MM_SolicitudPedido AS SP
            INNER JOIN MM_TipoSolicitudPedido AS TSP
                ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
            INNER JOIN TA_Operacion AS O
                ON O.IdDocumento = SP.IdSolicitudPedido
                   AND O.IdTipoOperacion = 6
            LEFT JOIN TA_Vencimiento AS V
                ON V.IdVencimiento = O.IdVigencia
            INNER JOIN TA_Estatus AS E
                ON E.IdEstatus = O.IdEstatusOperacion
            LEFT JOIN MM_PeticionOferta AS PO
                ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
			LEFT JOIN #CompradorAsignado AS SPC
					ON SPC.IdSolicitudPedido = SP.IdSolicitudPedido	
			LEFT JOIN #DISPONIBILIDADOFERTASDETALLE AS DO
					ON DO.IdSolicitudPedido = SP.IdSolicitudPedido
			LEFT JOIN dbo.DEA_AdjuntoPR AS PRDEA
				ON PRDEA.IdSolicitudPedido = SP.IdSolicitudPedido
			inner JOIN	Adinco.dbo.CO_Contrato			AS	C 
			ON			SP.IdContrato					=	C.IdContrato
        WHERE SP.IdProveedor = @IdProveedor
              AND O.FechaFinalizacion IS NOT NULL
              AND SP.IdTipoProceso = 2 -- Mercadeo
			  AND ISNULL(O.IdEstatusEliminado,0)<>1 --> DIFERENTE DE ESTATUS ELIMINADO
			  AND SPC.IdSolicitudPedido IS NOT NULL
        GROUP BY SP.IdSolicitudPedido,
                 TSP.TipoSolicitudPedido,
                 O.Descripcion,
                 O.FechaRegistro,
                 O.FechaFinalizacion,
				 O.IdEstatusEliminado,
				 DO.OfertaVencida,
				 PRDEA.ID_PR,
				 c.NumeroContrato
        ORDER BY SP.IdSolicitudPedido DESC

    END
--- IdTipoOperacion = 6 --> Peticion Oferta

END

