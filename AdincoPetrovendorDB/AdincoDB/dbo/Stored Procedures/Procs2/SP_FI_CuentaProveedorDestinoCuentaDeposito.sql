-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2020-11-23
-- Description:	Se toma de base el sp [SP_FI_CuentaProveedorDestino] perteneciente a transferencia, con finalida de filtrar por cuenta deposito
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_CuentaProveedorDestinoCuentaDeposito] --10597,'0115252180'
@IdSubcontratista INT,
@cuentaDeposito varchar(50)
AS
     BEGIN
         SET NOCOUNT ON;
         SELECT CB.DatoBancarioID,
                concat(C.RazonSocial, ' (', Isnull(S.NombreComercial, 'S/N'), ') ', ' - ', Isnull(CB.NumeroCuenta, CB.CuentaClave), ' - ', TM.TipoMonedaCorto) AS Cuenta,
                CB.Predeterminado,
                CB.TipoMonedaID
         FROM 
			PV_CuentaBancaria CB
		JOIN 
			PV_Banco C 
			ON CB.BancoID = C.BancoID
		JOIN 
			PV_TipoMoneda TM 
			ON CB.TipoMonedaID = tm.idmoneda
		LEFT JOIN 
			PV_Subcontratista S 
			ON CB.IdProveedor = S.IdSubcontratista
         WHERE 
			S.IdSubcontratista = @IdSubcontratista
			AND
			CB.CuentaClave =	@cuentaDeposito
     END;

	 


	 
