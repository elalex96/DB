-- =============================================
-- Author:		Manuel CD
-- Create date: 25-08-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_CuentaProveedorDestino] 
	-- Add the parameters for the stored procedure here
@IdSubcontratista INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT CB.DatoBancarioID,
                concat(C.RazonSocial, ' (', Isnull(S.NombreComercial, 'S/N'), ') ', ' - ', Isnull(CB.NumeroCuenta, CB.CuentaClave), ' - ', TM.TipoMonedaCorto) AS Cuenta,
                CB.Predeterminado,
                CB.TipoMonedaID
         FROM PV_CuentaBancaria CB
              LEFT JOIN PV_Subcontratista S ON CB.IdProveedor = S.IdSubcontratista
              INNER JOIN PV_Banco C ON CB.BancoID = C.BancoID
              JOIN PV_TipoMoneda TM ON CB.TipoMonedaID = tm.idmoneda
         WHERE S.IdSubcontratista = @IdSubcontratista;

	    --SP_FI_CuentaProveedorDestino 10042
	    --SP_FI_CuentaProveedorDestino 10080
     END;

