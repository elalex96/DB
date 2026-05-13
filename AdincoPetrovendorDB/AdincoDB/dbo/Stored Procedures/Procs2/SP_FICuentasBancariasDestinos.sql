-- =============================================
-- Author:		Manuel Cruz
-- Create date: 07-06-17
-- Description:	
-- =============================================
CREATE PROCEDURE SP_FICuentasBancariasDestinos 
	-- Add the parameters for the stored procedure here
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
    -- Insert statements for procedure here

             SELECT B.DatoBancarioID,
                    concat(C.RazonSocial, ' (', Isnull(A.NombreComercial, 'S/N'), ') ', ' - ', Isnull(B.NumeroCuenta, B.CuentaClave), ' - ', tm.TipoMonedaCorto) AS Cuenta
             FROM PV_CuentaBancaria B
                  LEFT JOIN PV_Subcontratista A ON B.IdProveedor = A.IdSubcontratista
                  INNER JOIN PV_Banco C ON B.BancoID = C.BancoID
                  JOIN PV_TipoMoneda tm ON b.TipoMonedaID = tm.idmoneda
             ORDER BY B.DatoBancarioID DESC;
             
	    --exec SP_FICuentasBancariasDestinos 10003
     END;
