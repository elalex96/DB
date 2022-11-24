
create proc sp_InvoiceList_grd
(
	@pIdContrato	int
)
as
begin


	SELECT PCP.idcontrato, 
		   RPCP.idproveedorventa, 
		   vendorname, 
		   RPCP.idpedido, 
		   PCP.foliocomprobante, 
		   PCP.numeropedimento, 
		   PCP.fechapago, 
		   PCPD.preciounitario, 
		   CASE 
			 WHEN PCPD.idunidadmedida = 1 THEN 'Material' 
			 WHEN PCPD.idunidadmedida = 2 THEN 'Service' 
		   END AS Unidad, 
		   TM.tipomonedacorto, 
		   PCPD.descripcionmercancia, 
		   RPCP.idrelacionpedimentocomprobante 
	FROM   dbo.mpy_fi_relacionpedimentocomprobantepedido AS RPCP 
		   LEFT JOIN adinco..co_sapvendor ven 
				  ON ven.vendoridsap COLLATE modern_spanish_ci_as = 
					 RPCP.idproveedorventa COLLATE modern_spanish_ci_as 
		   LEFT JOIN adinco.dbo.fi_pedimentocomprobante AS PCA 
				  ON PCA.idpedimentocomprobante = RPCP.idpedimentocomprobanteadinco 
		   LEFT JOIN dbo.fi_pedimentocomprobante AS PCP 
				  ON PCP.idpedimentocomprobante = 
					 PCA.idpedimentocomprobantepetrovendor 
		   LEFT JOIN dbo.fi_pedimentocomprobantedetalle AS PCPD 
				  ON PCPD.idpedimentocomprobante = PCP.idpedimentocomprobante 
		   --LEFT JOIN dbo.PV_MM_MaterialUnidad AS UN ON UN.IdUnidad = PCPD.IdUnidadMedida 
		   LEFT JOIN dbo.pv_tipomoneda AS TM 
				  ON TM.idmoneda = PCP.idmoneda 
		   LEFT JOIN dbo.s_proveedor AS PR 
				  ON PR.idproveedor = PCP.idsubcontratistaexportador 
		   LEFT JOIN dbo.s_proveedor AS OP 
				  ON OP.idproveedor = PCP.idsubcontratistaimportador 
	WHERE  PCP.idcontrato = @pIdContrato 
	order by  RPCP.idpedido 
end

