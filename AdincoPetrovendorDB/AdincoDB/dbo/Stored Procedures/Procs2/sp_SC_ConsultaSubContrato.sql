USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_SC_ConsultaSubContrato'
)
    DROP PROCEDURE sp_SC_ConsultaSubContrato; 
	GO 
/****** Object:  StoredProcedure [dbo].[sp_SC_ConsultaSubContrato]    Script Date: 10/07/2023 09:23:54 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: <11/07/202>
-- Description:	SP SE USA EN PAGINA ConsultaOTConvenio DE PETROVENDOR
-- =============================================|
CREATE Proc [dbo].[sp_SC_ConsultaSubContrato]
@pIdSubContrato int
As
SET NOCOUNT ON;
	select sc.IdSubContrato,
			sc.IdSubContratista,
			sc.IdContratista,
			sc.NumeroSubContrato,
			c.NombreContratista,
			NombreSubContratista = psc.RazonSocial,
			FechaRegistro = sc.CreadoEl,
			sc.Objeto,
			IdPedido = ISNULL(sc.IdPedido,0),
			PrefijoOT = ISNULL(sc.PrefijoOT,''),
			FolioOTSig =ISNULL(sc.PrefijoOT,'') +'-'+ CAST(ISNULL(COUNT(DISTINCT otSol.IdOTSolicitud),0) + 1 AS varchar) ,
			IdPresupuesto = ISNULL(pre.IdPresupuesto,0),
			IdProveedor = prov.IdProveedor,
			FolioPedido = folio.IdPedido,
			sc.FechaInicio,
			sc.FechaFin,
			sc.IdCentroCosto,
			sc.IdMoneda
	from SC_Subcontrato sc (NOLOCK)
	INNER JOIN CO_Contratista c (NOLOCK)
		on sc.IdContratista = c.IdContratista
	INNER JOIN pv_Subcontratista psc (NOLOCK)
		on sc.IdSubContratista = psc.IdSubContratista 
	LEFT JOIN dbo.SC_Presupuesto PRE (NOLOCK)
		ON SC.IdSubContrato = PRE.IdSubContrato
	LEFT JOIN dbo.OT_Solicitud otSol  (NOLOCK)
		ON sc.IdSubContrato = otSol.IdSubContrato
	LEFT join Petrovendor.dbo.S_Proveedor prov  (NOLOCK)
		on psc.RFC collate SQL_Latin1_General_CP1_CI_AS = prov.RFC collate SQL_Latin1_General_CP1_CI_AS
	LEFT join Petrovendor.dbo.MM_Pedidos folio  (NOLOCK)
		on sc.IdPedido = folio.IdIdentificador
	where sc.IdSubContrato = @pIdSubContrato
	GROUP BY sc.IdSubContrato,
			sc.IdSubContratista,
			sc.IdContratista,
			sc.NumeroSubContrato,
			c.NombreContratista,
			psc.RazonSocial,
			sc.CreadoEl,
			sc.Objeto,
			sc.IdPedido,
			sc.PrefijoOT,
			pre.IdPresupuesto,
			prov.IdProveedor,
			folio.IdPedido,
			sc.FechaInicio,
			sc.FechaFin,
			sc.IdCentroCosto,
			sc.IdMoneda

