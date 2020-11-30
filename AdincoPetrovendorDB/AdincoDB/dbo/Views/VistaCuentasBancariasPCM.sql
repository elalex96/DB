CREATE VIEW [dbo].[VistaCuentasBancariasPCM]
AS
     SELECT DISTINCT 
            CB.DatoBancarioID, 
            SC.RFC, 
            UPPER(SC.RazonSocial) AS RazonSocial, 
            UPPER(B.Banco) AS Banco, 
            CB.Titular, 
            cb.Sucursal, 
            cb.NumeroCuenta, 
            cb.CuentaClave, 
            MO.TipoMonedaCorto
     FROM dbo.PV_CuentaBancaria CB
          LEFT JOIN dbo.PV_Subcontratista SC ON CB.IdProveedor = SC.IdSubcontratista
          LEFT JOIN dbo.PV_Banco B ON B.BancoID = CB.BancoID
          LEFT JOIN dbo.PV_TipoMoneda MO ON CB.TipoMonedaID = MO.IdMoneda
          --LEFT JOIN dbo.PV_TipoCuentaBancaria TCB ON TCB.IdTipoCuenta = CB.IdTipoCuenta
          LEFT JOIN dbo.FI_Transfer TR ON tr.IdCuentaDestino = CB.DatoBancarioID
     WHERE TR.IdContrato = 10036;
