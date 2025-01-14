IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_SC_ConsultaSubContrato'
)
    DROP PROCEDURE sp_SC_ConsultaSubContrato
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: <11/07/202>
-- Description:	SP SE USA EN PAGINA ConsultaOTConvenio DE PETROVENDOR
-- =============================================|
CREATE PROC sp_SC_ConsultaSubContrato
@pIdSubContrato INT
AS
BEGIN
SET NOCOUNT ON;
	SELECT  SC_Subcontrato.IdSubContrato,
			SC_Subcontrato.IdSubContratista,
			SC_Subcontrato.IdContratista,
			SC_Subcontrato.NumeroSubContrato,
			CO_Contratista.NombreContratista,
			NombreSubContratista = pv_Subcontratista.RazonSocial,
			FechaRegistro = SC_Subcontrato.CreadoEl,
			SC_Subcontrato.Objeto,
			IdPedido = ISNULL(SC_Subcontrato.IdPedido, 0),
			PrefijoOT = ISNULL(SC_Subcontrato.PrefijoOT, ''),
			FolioOTSig =ISNULL(SC_Subcontrato.PrefijoOT, '') + '-' + CAST(ISNULL(COUNT(DISTINCT OT_Solicitud.IdOTSolicitud), 0) + 1 AS VARCHAR) ,
			IdPresupuesto = ISNULL(SC_Presupuesto.IdPresupuesto, 0),
			IdProveedor = S_Proveedor.IdProveedor,
			FolioPedido = MM_Pedidos.IdPedido,
			SC_Subcontrato.FechaInicio,
			SC_Subcontrato.FechaFin,
			SC_Subcontrato.IdCentroCosto,
			SC_Subcontrato.IdMoneda
	FROM SC_Subcontrato (NOLOCK)
	INNER JOIN CO_Contratista (NOLOCK)
		ON SC_Subcontrato.IdContratista = CO_Contratista.IdContratista
			AND SC_Subcontrato.IdSubContrato = @pIdSubContrato
	INNER JOIN pv_Subcontratista (NOLOCK)
		ON SC_Subcontrato.IdSubContratista = pv_Subcontratista.IdSubContratista 
	LEFT JOIN dbo.SC_Presupuesto (NOLOCK)
		ON SC_Subcontrato.IdSubContrato = SC_Presupuesto.IdSubContrato
	LEFT JOIN dbo.OT_Solicitud  (NOLOCK)
		ON SC_Subcontrato.IdSubContrato = OT_Solicitud.IdSubContrato
	LEFT JOIN Petrovendor.dbo.S_Proveedor (NOLOCK)
		ON pv_Subcontratista.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = S_Proveedor.RFC COLLATE SQL_Latin1_General_CP1_CI_AS
	LEFT JOIN Petrovendor.dbo.MM_Pedidos (NOLOCK)
		ON SC_Subcontrato.IdPedido = MM_Pedidos.IdIdentificador
	WHERE SC_Subcontrato.IdSubContrato = @pIdSubContrato
	GROUP BY SC_Subcontrato.IdSubContrato,
			SC_Subcontrato.IdSubContratista,
			SC_Subcontrato.IdContratista,
			SC_Subcontrato.NumeroSubContrato,
			CO_Contratista.NombreContratista,
			pv_Subcontratista.RazonSocial,
			SC_Subcontrato.CreadoEl,
			SC_Subcontrato.Objeto,
			SC_Subcontrato.IdPedido,
			SC_Subcontrato.PrefijoOT,
			SC_Presupuesto.IdPresupuesto,
			S_Proveedor.IdProveedor,
			MM_Pedidos.IdPedido,
			SC_Subcontrato.FechaInicio,
			SC_Subcontrato.FechaFin,
			SC_Subcontrato.IdCentroCosto,
			SC_Subcontrato.IdMoneda

END

