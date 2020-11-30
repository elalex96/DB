-- =============================================
-- Author:          josue glez
-- Create date: 24/05/2017
-- Description:     Listado de cuentas bancarias para llenar combobox
-- =============================================
CREATE PROCEDURE [dbo].[SP_FICuentasBancarias] 
       -- Add the parameters for the stored procedure here
@IdContrato INT
AS
     BEGIN
       -- SET NOCOUNT ON added to prevent extra result sets from
       -- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @CONTRATISTA INT;--= 10000;
    --

         SELECT @CONTRATISTA = Ca.IdContratista
         FROM CO_Contrato Co
              JOIN CO_Contratista Ca ON Co.IdContratista = Ca.IdContratista
         WHERE Co.IdContrato = @IdContrato;
           
    -- Insert statements for procedure here

         --IF @CONTRATISTA = 10000
         --    BEGIN

         SELECT B.DatoBancarioID,
                concat( isnull(B.alias,'')  , ' ', C.RazonSocial, ' (', Isnull(A.NombreComercial, 'S/N'), ') ', ' - ', Isnull(B.NumeroCuenta, B.CuentaClave), ' - ', tm.TipoMonedaCorto) AS Cuenta
         FROM PV_CuentaBancaria B
              LEFT JOIN PV_Subcontratista A ON B.IdProveedor = A.IdSubcontratista
              INNER JOIN PV_Banco C ON B.BancoID = C.BancoID
              JOIN PV_TipoMoneda tm ON b.TipoMonedaID = tm.idmoneda
         WHERE B.IdContratista = @CONTRATISTA
         ORDER BY B.DatoBancarioID DESC;
         --END;
         --    ELSE
         --    BEGIN
         --        SELECT B.DatoBancarioID,
         --               concat(C.RazonSocial, ' (', Isnull(A.NombreComercial, 'S/N'), ') ', ' - ', Isnull(B.NumeroCuenta, B.CuentaClave), ' - ', tm.TipoMonedaCorto) AS Cuenta
         --        FROM PV_CuentaBancaria B
         --             LEFT JOIN PV_Subcontratista A ON B.IdProveedor = A.IdSubcontratista
         --             INNER JOIN PV_Banco C ON B.BancoID = C.BancoID
         --             JOIN PV_TipoMoneda tm ON b.TipoMonedaID = tm.idmoneda
         --        ORDER BY B.DatoBancarioID DESC;
         --END;

           /*
           ---FILTRADO POR REGISTRO DE IDPROVEEDOR DEL CONTRATISTA

         SELECT B.DatoBancarioID,
                concat(C.RazonSocial, ' (', Isnull(A.NombreComercial, 'S/N'), ') ', ' - ', Isnull(B.NumeroCuenta, B.CuentaClave), ' - ', tm.TipoMonedaCorto) AS Cuenta
         FROM PV_CuentaBancaria B
              JOIN PV_Subcontratista A ON B.IdProveedor = A.IdSubcontratista
              JOIN PV_Banco C ON B.BancoID = C.BancoID
              JOIN PV_TipoMoneda tm ON b.TipoMonedaID = tm.idmoneda
              JOIN CO_Contratista CC ON A.IdSubcontratista = CC.IdProveedor
              JOIN CO_Contrato CN ON CN.IdContratista = CC.IdContratista
         WHERE CN.IdContrato = @IdContrato
         ORDER BY B.DatoBancarioID DESC;
           */

--exec SP_FICuentasBancarias 10005
     END;