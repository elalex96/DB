
-- =============================================

-- Author: Pedro Acu�a

-- Create date: 01-07-19

-- Description: Obtener los RFC que deben de validar el metodo de pago tipo PUE

-- =============================================

CREATE 
PROCEDURE [dbo].[SP_ObtenerRFCsMetodoPagoFacturaPUEInvalido] 

AS

BEGIN
--Se modifica (viernes 20 Dic)a petición de Fernando (tickets 4257 4283)
--se activa candado para no cargar PUE's 07/02/2020 t4764
SELECT RFC 
FROM dbo.S_Proveedor WHERE IdProveedor
IN (606, 690)
-- (-1)
END

