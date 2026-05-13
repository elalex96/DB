CREATE VIEW dbo.CB_Jaguar_CuentasBancarias AS

SELECT  DISTINCT 
	CB.DatoBancarioID, SC.RFC, SC.RazonSocial,  B.Banco, CB.Titular, cb.Sucursal, cb.NumeroCuenta, cb.CuentaClave
FROM 
	dbo.PV_CuentaBancaria CB  WITH (NOLOCK)
LEFT JOIN
	dbo.PV_Subcontratista SC   WITH (NOLOCK)
	ON CB.IdProveedor = SC.IdSubcontratista
LEFT JOIN
	dbo.PV_Banco B WITH (NOLOCK)
	ON B.BancoID = CB.BancoID
LEFT JOIN
	dbo.VU_MonedaXML MO WITH (NOLOCK)
	ON CB.TipoMonedaID = MO.IdMonedaXML
LEFT JOIN
	dbo.PV_TipoCuentaBancaria TCB WITH (NOLOCK)
	ON TCB.IdTipoCuenta = CB.IdTipoCuenta
LEFT JOIN
	dbo.FI_Transfer TR WITH (NOLOCK)
	ON tr.IdCuentaDestino = CB.DatoBancarioID
LEFT JOIN
	dbo.FI_TransferFactura TRFA WITH (NOLOCK)
	ON TRFA.IdTransfer = TR.IdTransferencia
LEFT JOIN
	CO_Contrato C WITH (NOLOCK)
	ON TR.IdContrato= C.IdContrato
LEFT JOIN
	CO_Contratista CT WITH (NOLOCK)
	ON C.IdContratista= CT.IdContratista
WHERE
	CT.NombreContratista in ('Jaguar','Pantera','Jaguar Corporativo', 'JEYP SERVICIOS') 
