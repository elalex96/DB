USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_mm_rpt_consultapedidosreporte'
)
    DROP PROCEDURE sp_mm_rpt_consultapedidosreporte;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:  <Alexander Gomez>  
-- Create date: 12/03/2024
-- Description: Adecuacion para consultar todos los contratos
-- =============================================  
CREATE PROC [dbo].[sp_mm_rpt_consultapedidosreporte]
  @FechaInicio DATE,
  @FechaFin DATE,
  @IdContrato Int = null,
  @ReporteExcel BIT = null
AS
  BEGIN
    DECLARE @EsAdministrador  INT= 0,
      @EsTipoAdministrador    BIT = 0,
      @EsAdministradorCompras BIT;
    DROP TABLE
    if exists #mm_solicitudpedidocompradort
    CREATE TABLE #mm_solicitudpedidocompradort
                 (
                              idsolicitudpedido INT
                 );
    
    INSERT INTO #mm_solicitudpedidocompradort
                (
                            idsolicitudpedido
                )
    SELECT     p.idsolicitudpedido
    FROM       dbo.mm_pedido P (nolock)
    INNER JOIN dbo.mm_solicitudpedido SP (nolock)
    ON         p.idsolicitudpedido = sp.idsolicitudpedido
    INNER JOIN dbo.mm_solicitudpedidocomprador SPC (nolock)
    ON         p.idsolicitudpedido = spc.idsolicitudpedido
    WHERE      Isnull(spc.activo, 0) = 1 -->CTE QUE ESTE ACTIVO
    GROUP BY   p.idsolicitudpedido;
    
    DROP TABLE
    if exists #wdea_purchasingdocumentsimportados
    CREATE TABLE #wdea_purchasingdocumentsimportados
                 (
                              idpedidoadinco         INT,
                              mecanismo_contratacion NVARCHAR(max)
                 );
    
    INSERT INTO #wdea_purchasingdocumentsimportados
                (
                            idpedidoadinco,
                            mecanismo_contratacion
                )
    SELECT   pdi.idpedidoadinco,
             Max(pdi.mecanismo_contratacion)
    FROM     mm_pedido P
    JOIN     wdea_purchasingdocumentsimportados PDI
    ON       p.idpedido = pdi.idpedidoadinco
    GROUP BY pdi.idpedidoadinco
    -------------------------------------
	IF ISNULL(@IdContrato,0) = 0
	BEGIN
    SELECT     c.numerocontrato as contrato,
               pg.idpedido        AS idpedido,
               p.idsolicitudpedido as requisicion,
               p.fechaenviopedido                                               AS fechaAlta,
               Sum(pd.subtotal)                                                 AS totalpedido,
			   tm.tipomonedacorto AS moneda,
               Isnull(pv.razonsocial, '') + ' ' + Isnull(pv.regimencapital, '') AS proveedor,
			   ISNULL(ADPO.ID_PO,'') as porelacionada,
               CASE
                          WHEN Isnull(pdi.mecanismo_contratacion,'')='L' THEN 'Licitación'
                          ELSE tp.tipopedido
               END AS tipopedido,
			   p.IdPedido as Pedido
    FROM       mm_pedido AS p (nolock)
    INNER JOIN dbo.mm_solicitudpedido SP (nolock)
    ON         p.idsolicitudpedido = sp.idsolicitudpedido
    INNER JOIN mm_pedidodetalle AS pd (nolock)
    ON         p.idpedido = pd.idpedido
    INNER JOIN s_proveedor AS pv (nolock)
    ON         p.idsubcontratista = pv.idproveedor
    INNER JOIN ta_operacion AS o (nolock)
    ON         p.idsolicitudpedido = o.iddocumento
    INNER JOIN mm_horasvigenciapedido AS hv (nolock)
    ON         p.idpedido = hv.idpedido
    INNER JOIN pv_tipomoneda AS tm (nolock)
    ON         p.idmoneda = tm.idmoneda
    INNER JOIN mm_pedidos AS pg (nolock)
    ON         p.idpedido = pg.ididentificador
    AND        pg.idtipopedido IN ( 2,
                                   4,
                                   6 ) -->(Mer, AD, OT)
    INNER JOIN adinco.dbo.co_contrato AS c (nolock)
    ON         sp.idcontrato = c.idcontrato
    LEFT JOIN  dbo.mm_tipopedido AS tp (nolock)
    ON         pg.idtipopedido = tp.idtipopedido
    LEFT JOIN  #mm_solicitudpedidocompradort SPC (nolock)
    ON         p.idsolicitudpedido = spc.idsolicitudpedido
    LEFT JOIN  #wdea_purchasingdocumentsimportados PDI (nolock)
    ON         p.idpedido = pdi.idpedidoadinco
	LEFT JOIN DEA_Relacion_PR_PO RPO
	ON P.IdPedido = RPO.idpedido
	LEFT JOIN dbo.DEA_AdjuntoPO AS ADPO 
			ON RPO.IdAdjuntoPO=ADPO.IdAdjuntoPO
    WHERE      o.idtipooperacion = 9 --> APROBACIÓN DE PEDIDO
    AND        p.recepcionservicio = 1              --> RECEPCIÓN ACEPTADA
    AND        o.idestatusoperacion = 2                      --> ESTATUS APROBADO (TODOS LOS PEDIDOS RECEPCIONADOS DEBEN SER APROBADOS PRIMERO)
    AND        hv.fechavigencia IS NOT NULL         --> DEBE HABER UNA FECHA DE VIGENCIA DE RECEPCIÓN
    AND        p.version = o.noversion              --> LA VERSIÓN DE PEDIDO DEBE SER LA MISMA QUE LA DE LA OPERACIÓN
    AND        Isnull(p.idestatuseliminado, 0) <> 1 --> QUE NO ESTE ELIMINADO EL PEDIDO
    AND        Isnull(p.cerrado, 0) = 0             --> PEDIDOS NO CERRADOS
			   AND (p.fechaenviopedido >= @FechaInicio and p.fechaenviopedido <= @FechaFin)
			   AND SP.IdContrato IN (10045,10044,10046,10038,10144)
    GROUP BY   p.idpedido,
			   pv.razonsocial,
			   pv.RegimenCapital,
               p.idsolicitudpedido,
               p.fechaenviopedido,
               pv.razonsocial,
               tm.tipomonedacorto,
               pg.idpedido,
			   pdi.mecanismo_contratacion,
               tp.tipopedido,
               tp.idtipopedido,
               c.numerocontrato,
			   ADPO.ID_PO,
			   p.IdPedido,
			   c.IdContrato
    ORDER BY   pg.idpedido DESC;
	END
	ELSE
	BEGIN

	IF @ReporteExcel = 1
	BEGIN

		SELECT c.numerocontrato as 'Contrato',
               pg.idpedido        AS 'Pedido',
               p.idsolicitudpedido as 'Requisición',
               p.fechaenviopedido                                               AS 'Fecha de alta',
               CONCAT('$',format(Sum(pd.subtotal), N'#,##0.##########', 'de-DE')) AS 'Total Pedido',
			   tm.tipomonedacorto AS 'Moneda',
               Isnull(pv.razonsocial, '') + ' ' + Isnull(pv.regimencapital, '') AS Proveedor,
			   ISNULL(ADPO.ID_PO,'') as 'PO Relacionada',
               CASE
                          WHEN Isnull(pdi.mecanismo_contratacion,'')='L' THEN 'Licitación'
                          ELSE tp.tipopedido
               END AS 'Tipo Pedido',
			   p.IdPedido as PedidoInterno
			FROM       mm_pedido AS p (nolock)
			INNER JOIN dbo.mm_solicitudpedido SP (nolock)
			ON         p.idsolicitudpedido = sp.idsolicitudpedido
			INNER JOIN mm_pedidodetalle AS pd (nolock)
			ON         p.idpedido = pd.idpedido
			INNER JOIN s_proveedor AS pv (nolock)
			ON         p.idsubcontratista = pv.idproveedor
			INNER JOIN ta_operacion AS o (nolock)
			ON         p.idsolicitudpedido = o.iddocumento
			INNER JOIN mm_horasvigenciapedido AS hv (nolock)
			ON         p.idpedido = hv.idpedido
			INNER JOIN pv_tipomoneda AS tm (nolock)
			ON         p.idmoneda = tm.idmoneda
			INNER JOIN mm_pedidos AS pg (nolock)
			ON         p.idpedido = pg.ididentificador
			AND        pg.idtipopedido IN ( 2,
										   4,
										   6 ) -->(Mer, AD, OT)
			INNER JOIN adinco.dbo.co_contrato AS c (nolock)
			ON         sp.idcontrato = c.idcontrato
			LEFT JOIN  dbo.mm_tipopedido AS tp (nolock)
			ON         pg.idtipopedido = tp.idtipopedido
			LEFT JOIN  #mm_solicitudpedidocompradort SPC (nolock)
			ON         p.idsolicitudpedido = spc.idsolicitudpedido
			LEFT JOIN  #wdea_purchasingdocumentsimportados PDI (nolock)
			ON         p.idpedido = pdi.idpedidoadinco
			LEFT JOIN DEA_Relacion_PR_PO RPO
			ON P.IdPedido = RPO.idpedido
			LEFT JOIN dbo.DEA_AdjuntoPO AS ADPO 
					ON RPO.IdAdjuntoPO=ADPO.IdAdjuntoPO
			WHERE      o.idtipooperacion = 9 --> APROBACIÓN DE PEDIDO
			AND        p.recepcionservicio = 1              --> RECEPCIÓN ACEPTADA
			AND        o.idestatusoperacion = 2                      --> ESTATUS APROBADO (TODOS LOS PEDIDOS RECEPCIONADOS DEBEN SER APROBADOS PRIMERO)
			AND        hv.fechavigencia IS NOT NULL         --> DEBE HABER UNA FECHA DE VIGENCIA DE RECEPCIÓN
			AND        p.version = o.noversion              --> LA VERSIÓN DE PEDIDO DEBE SER LA MISMA QUE LA DE LA OPERACIÓN
			AND        Isnull(p.idestatuseliminado, 0) <> 1 --> QUE NO ESTE ELIMINADO EL PEDIDO
			AND        Isnull(p.cerrado, 0) = 0             --> PEDIDOS NO CERRADOS
					   AND p.fechaenviopedido between @FechaInicio and @FechaFin
					   AND SP.IdContrato = @IdContrato
			GROUP BY   p.idpedido,
					   pv.razonsocial,
					   pv.RegimenCapital,
					   p.idsolicitudpedido,
					   p.fechaenviopedido,
					   pv.razonsocial,
					   tm.tipomonedacorto,
					   pg.idpedido,
					   pdi.mecanismo_contratacion,
					   tp.tipopedido,
					   tp.idtipopedido,
					   c.numerocontrato,
					   ADPO.ID_PO,
					   p.IdPedido,
					   c.IdContrato
			ORDER BY   pg.idpedido DESC;

	END
	ELSE
	BEGIN

			SELECT     c.numerocontrato as contrato,
					   pg.idpedido        AS idpedido,
					   p.idsolicitudpedido as requisicion,
					   p.fechaenviopedido as fechaAlta,
					   CONCAT('$',format(Sum(pd.subtotal), N'#,##0.##########', 'de-DE')) AS totalpedido,
					   tm.tipomonedacorto AS moneda,
					   Isnull(pv.razonsocial, '') + ' ' + Isnull(pv.regimencapital, '') AS proveedor,
					   ISNULL(ADPO.ID_PO,'') as porelacionada,
					   CASE
								  WHEN Isnull(pdi.mecanismo_contratacion,'')='L' THEN 'Licitación'
								  ELSE tp.tipopedido
					   END AS tipopedido,
					   p.IdPedido as Pedido
			FROM       mm_pedido AS p (nolock)
			INNER JOIN dbo.mm_solicitudpedido SP (nolock)
			ON         p.idsolicitudpedido = sp.idsolicitudpedido
			INNER JOIN mm_pedidodetalle AS pd (nolock)
			ON         p.idpedido = pd.idpedido
			INNER JOIN s_proveedor AS pv (nolock)
			ON         p.idsubcontratista = pv.idproveedor
			INNER JOIN ta_operacion AS o (nolock)
			ON         p.idsolicitudpedido = o.iddocumento
			INNER JOIN mm_horasvigenciapedido AS hv (nolock)
			ON         p.idpedido = hv.idpedido
			INNER JOIN pv_tipomoneda AS tm (nolock)
			ON         p.idmoneda = tm.idmoneda
			INNER JOIN mm_pedidos AS pg (nolock)
			ON         p.idpedido = pg.ididentificador
			AND        pg.idtipopedido IN ( 2,
										   4,
										   6 ) -->(Mer, AD, OT)
			INNER JOIN adinco.dbo.co_contrato AS c (nolock)
			ON         sp.idcontrato = c.idcontrato
			LEFT JOIN  dbo.mm_tipopedido AS tp (nolock)
			ON         pg.idtipopedido = tp.idtipopedido
			LEFT JOIN  #mm_solicitudpedidocompradort SPC (nolock)
			ON         p.idsolicitudpedido = spc.idsolicitudpedido
			LEFT JOIN  #wdea_purchasingdocumentsimportados PDI (nolock)
			ON         p.idpedido = pdi.idpedidoadinco
			LEFT JOIN DEA_Relacion_PR_PO RPO
			ON P.IdPedido = RPO.idpedido
			LEFT JOIN dbo.DEA_AdjuntoPO AS ADPO 
					ON RPO.IdAdjuntoPO=ADPO.IdAdjuntoPO
			WHERE      o.idtipooperacion = 9 --> APROBACIÓN DE PEDIDO
			AND        p.recepcionservicio = 1              --> RECEPCIÓN ACEPTADA
			AND        o.idestatusoperacion = 2                      --> ESTATUS APROBADO (TODOS LOS PEDIDOS RECEPCIONADOS DEBEN SER APROBADOS PRIMERO)
			AND        hv.fechavigencia IS NOT NULL         --> DEBE HABER UNA FECHA DE VIGENCIA DE RECEPCIÓN
			AND        p.version = o.noversion              --> LA VERSIÓN DE PEDIDO DEBE SER LA MISMA QUE LA DE LA OPERACIÓN
			AND        Isnull(p.idestatuseliminado, 0) <> 1 --> QUE NO ESTE ELIMINADO EL PEDIDO
			AND        Isnull(p.cerrado, 0) = 0             --> PEDIDOS NO CERRADOS
					   AND p.fechaenviopedido between @FechaInicio and @FechaFin
					   AND SP.IdContrato = @IdContrato
			GROUP BY   p.idpedido,
					   pv.razonsocial,
					   pv.RegimenCapital,
					   p.idsolicitudpedido,
					   p.fechaenviopedido,
					   pv.razonsocial,
					   tm.tipomonedacorto,
					   pg.idpedido,
					   pdi.mecanismo_contratacion,
					   tp.tipopedido,
					   tp.idtipopedido,
					   c.numerocontrato,
					   ADPO.ID_PO,
					   p.IdPedido,
					   c.IdContrato
			ORDER BY   pg.idpedido DESC;	

		END

	END

  END 