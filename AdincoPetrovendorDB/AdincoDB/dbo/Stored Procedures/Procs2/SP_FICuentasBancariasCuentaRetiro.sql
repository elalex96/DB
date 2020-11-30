-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2020-11-23
-- Description:	Se toma de base el sp [SP_FICuentasBancarias] perteneciente a transferencia, con finalida de filtrar por cuenta retiro
-- =============================================
CREATE PROCEDURE [dbo].[SP_FICuentasBancariasCuentaRetiro]--3, '000000000112173743'
@IdContrato INT,
@CuentaRetiro varchar(50)
AS
     BEGIN
         SET NOCOUNT ON;
         DECLARE @CONTRATISTA INT;

         SELECT @CONTRATISTA = Ca.IdContratista
         FROM 
			CO_Contrato Co
         JOIN
			 CO_Contratista Ca 
			 ON Co.IdContratista = Ca.IdContratista
         WHERE Co.IdContrato = @IdContrato;


         SELECT B.DatoBancarioID,
                concat(C.RazonSocial, ' (', Isnull(A.NombreComercial, 'S/N'), ') ', ' - ', Isnull(B.NumeroCuenta, B.CuentaClave), ' - ', tm.TipoMonedaCorto) AS Cuenta
         FROM 
			PV_CuentaBancaria B
		JOIN 
			PV_Banco C 
			ON B.BancoID = C.BancoID
		JOIN 
			PV_TipoMoneda tm 
			ON B.TipoMonedaID = tm.idmoneda
		LEFT JOIN 
			PV_Subcontratista A 
			ON B.IdProveedor = A.IdSubcontratista

         WHERE B.IdContratista = @CONTRATISTA
				AND B.CuentaClave = @CuentaRetiro
         ORDER BY B.DatoBancarioID DESC;
     
     END;

