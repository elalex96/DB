create PROCEDURE [dbo].[p_MPY_CancelarPO]
@SAPPONumber varchar(20),
@IdUsuario int
as
begin
declare @CantidadDocs int;

	set @CantidadDocs= (
		SELECT
		COUNT(*)
		FROM dbo.MPY_FI_RelacionPedimentoComprobantePedido AS RPCP
		LEFT JOIN Adinco.dbo.FI_PedimentoComprobante AS PCA ON PCA.IdPedimentoComprobante = RPCP.IdPedimentoComprobanteADINCO
		LEFT JOIN dbo.FI_PedimentoComprobante AS PCP ON PCP.IdPedimentoComprobante = PCA.IdPedimentoComprobantePetrovendor
		LEFT JOIN dbo.FI_PedimentoComprobanteDetalle AS PCPD ON PCPD.IdPedimentoComprobante = PCP.IdPedimentoComprobante
		--LEFT JOIN dbo.PV_MM_MaterialUnidad AS UN ON UN.IdUnidad = PCPD.IdUnidadMedida
		LEFT JOIN dbo.PV_TipoMoneda AS TM ON TM.IdMoneda = PCP.IdMoneda
		LEFT JOIN dbo.S_Proveedor AS PR ON PR.IdProveedor = PCP.IdSubcontratistaExportador
		LEFT JOIN dbo.S_Proveedor AS OP ON OP.IdProveedor = PCP.IdSubcontratistaImportador
		WHERE RPCP.IdPedido = @SAPPONumber
	);

	if @CantidadDocs = 0
	begin
		Update Adinco..CO_SAPPO
			set POActivo = 0,
			CancaladoEl = GETDATE(),
			CancaladoPor = @IdUsuario
			where SAPPONumber = @SAPPONumber
	end
	else
	begin
		select 	'The PO you try to cancel has attached bills.' as 'CantidadDocs'
	end
end