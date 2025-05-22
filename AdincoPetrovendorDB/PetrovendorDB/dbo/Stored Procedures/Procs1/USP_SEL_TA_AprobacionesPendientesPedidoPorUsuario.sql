USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_TA_AprobacionesPendientesPedidoPorUsuario'
)
 DROP PROCEDURE USP_SEL_TA_AprobacionesPendientesPedidoPorUsuario;
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author: Daniel AC  
-- Create date: 05-05-2025  
-- Description: consultar tareas de pedido pendientes de aprobación
-- =============================================  
CREATE PROCEDURE [dbo].[USP_SEL_TA_AprobacionesPendientesPedidoPorUsuario]
    @ContratoId INT,
    @AprobadorActualId INT,
	@ProveedorId INT
AS
BEGIN
		
	DECLARE @FlujoSerial TABLE  
    (  
        IdOperacion INT,  
        NoSecuencia INT  
    );  
    DECLARE @OperacionNoAprobadas TABLE (IdOperacion INT);  

    INSERT INTO @FlujoSerial  
    (  
        IdOperacion,  
        NoSecuencia  
    )  
    SELECT O.IdOperacion,  
           t.NoSecuencia  
    FROM dbo.TA_Operacion O  
		JOIN dbo.TA_FlujoTarea FT 
			ON O.IdFlujoTarea=FT.IdFlujoTarea	 
		AND FT.IdTipoFlujo= 1 --> FLUJO DE APROBACIÓN SERIAL 
        LEFT JOIN dbo.MM_Pedido p  
            ON  O.IdDocumento   = p.IdSolicitudPedido 
               AND O.NoVersion   = p.Version 
        INNER JOIN dbo.TA_Tarea t  
            ON O.IdOperacion  = t.IdOperacion 
    WHERE O.IdTipoOperacion = 9  
          AND ISNULL(O.IdEstatusEliminado, 0) <> 1 -->APROBACIÓN NO ESTE ELIMINADO  
          AND t.IdAprobador = @AprobadorActualId  
          AND t.NoSecuencia > 1;  

    INSERT INTO @OperacionNoAprobadas  
    (  
        IdOperacion  
    )  
    SELECT O.IdOperacion  
    FROM dbo.TA_Operacion O  
        INNER JOIN @FlujoSerial f  
            ON O.IdOperacion  = f.IdOperacion 
        INNER JOIN dbo.TA_Tarea T  
            ON O.IdOperacion  = T.IdOperacion 
               AND T.NoSecuencia = (f.NoSecuencia - 1)  
    WHERE O.IdTipoOperacion = 9 --> CTE APROBACIONES DE PEDIDO
          AND T.IdEstatus <> 2;  --> NO ESTE APROBADAS
		   
    SELECT O.IdOperacion,  
		   T.IdTarea,
           SolicitudPedidoId = SP.IdSolicitudPedido,  
           O.FechaRegistro,  
		   Aprobador = U.Nombre,
           P2.IdPedido,
		   O.Descripcion,            
           FechaPedido = P.CreadoEl,
           Proveedor = PRO.RazonSocial,  
           P.Version,  
           P.IdSubcontratista,  
           SP.MotivoUrgencia ,
		   T.NoSecuencia,
		   TipoFlujo = TF.Nombre,
		   EsVisibleAlUsuario = (CASE WHEN ISNULL(ONP.IdOperacion,0) =  0 THEN 1 ELSE 0 END),
		   Contrato = AC.NombreAreaContractual
    FROM TA_Operacion AS O  
        JOIN MM_Pedido AS P 
			ON O.IdDocumento  = P.IdSolicitudPedido 
			AND O.IdTipoOperacion = 9   --> CTE APROBACIÓN DE PEDIDO
        JOIN MM_Pedidos P2 
			ON P.IdPedido = P2.IdIdentificador 
			AND P.IdProveedorCompras = P2.IdProveedorCliente
			AND P2.IdTipoPedido IN ( 2, 4, 6 ) 
		JOIN TA_FlujoTarea FT
			ON O.IdFlujoTarea = FT.IdFlujoTarea
		JOIN TA_TipoFlujoTarea TF
			ON FT.IdTipoFlujo = TF.IdTipoFlujoTarea			
        JOIN dbo.MM_SolicitudPedido SP 
			ON P.IdSolicitudPedido  =SP.IdSolicitudPedido        
        JOIN TA_Tarea AS T 
			ON O.IdOperacion = T.IdOperacion   
        JOIN dbo.S_Usuario U 
			ON T.IdAprobador  = U.IdUsuario  
        JOIN dbo.S_Proveedor PRO 
			ON  P.IdSubcontratista = PRO.IdProveedor 
		LEFT JOIN @OperacionNoAprobadas ONP
			ON O.IdOperacion = ONP.IdOperacion
		LEFT JOIN Adinco..CO_Contrato C
			ON P.IdContrato = C.IdContrato
		LEFT JOIN Adinco..CO_AreaContractual AC
			ON C.IdAreaContractual = AC.IdAreaContractual
    WHERE T.IdAprobador = @AprobadorActualId  
          AND O.IdProveedor = @ProveedorId  
          AND P.Version = O.NoVersion  
          AND ISNULL(O.IdEstatusEliminado, 0) <> 1 -->APROBACIÓN NO ESTE ELIMINADO  
          AND ISNULL(p.IdEstatusEliminado, 0) <> 1 -->PEDIDO NO ELIMINADO  
          AND T.IdEstatus = 1 --> CTE DEBE ESTAR EN APROBACIÓN  
    GROUP BY O.IdOperacion,  
             O.IdDocumento,  
             O.FechaRegistro,  
             O.Descripcion,              
             O.IdTipoOperacion,  
             P.Version,  
			 P.CreadoEl,
             PRO.RazonSocial,  
             P.IdSubcontratista,  
             SP.MotivoUrgencia, 
			 SP.IdSolicitudPedido,
             P2.IdPedido ,
			 T.NoSecuencia,
			 ONP.IdOperacion,
			 T.IdTarea,
			 TF.Nombre,
			 AC.NombreAreaContractual,
			 U.Nombre
    ORDER BY P2.IdPedido DESC;  
			

END

  