CREATE PROCEDURE [dbo].[SP_ObtenerRFCsMetodoPagoFacturaPUEInvalido] 
@Receptor NVARCHAR(MAX),
@MetodoPago  NVARCHAR(MAX),
@ProveedorActualId INT

AS

BEGIN
-- =============================================
-- Author: Pedro Acuña
-- Create date: 01-07-19
-- Description: Obtener los RFC que deben de validar el metodo de pago tipo PUE
-- =============================================
--Se modifica (viernes 20 Dic)a petición de Fernando (tickets 4257 4283)
--se activa candado para no cargar PUE's 07/02/2020 t4764
-- =============================================
-- Author: Daniel AC
-- Create date: 07-12-2021
-- Description: Validar si el RFC(Operadora) debe permite cargas de PUE y a que proveedor si le da permiso de cargar
-- =============================================
DECLARE @AplicaOperadora INT
DECLARE @NoAplicaProveedor INT


IF @MetodoPago NOT IN ('PUE')
BEGIN
SELECT 1 AS  PermitirCarga
RETURN 
END 

/*VALIDAR SI LA OPERADORA TIENE BLOQUEADO CARGA DE FACTURAS DE METODO DE PAGO PUE*/
SET @AplicaOperadora  = (SELECT COUNT(1) FROM dbo.S_Proveedor 
										  WHERE IdProveedor
										  IN (606, 690) --> OPERADORAS QUE NO PUEDEN CARGAR FACTURAS PUES
										  AND RTRIM(LTRIM(UPPER(RFC))) =RTRIM(LTRIM(UPPER(@Receptor))))

/*VALIDAR SI EL PROVEEDOR PUEDE CARGAR FACTURAS PUE */
SET @NoAplicaProveedor  = (SELECT COUNT(1) FROM dbo.S_Proveedor 
							WHERE RFC IN ('PDO070403RJ8')--> RFCS DE PROVEEDORES QUE PUEDEN CARGAR FACTURAS PUE -- 'ITS071026QB1',
							AND IdProveedor = @ProveedorActualId)

/*SI LA OPERADORA TIENE BLOQUEADO CARGA PERO SI EL PROVEEDOR ESTA EN LA LISTA DE PERMITIDOS SE DEBE PERMITIR CARGA DE FACTURAS PUE*/						
IF @AplicaOperadora > 0 AND @NoAplicaProveedor >0
BEGIN  
	SET @AplicaOperadora = 0
END 

SELECT CASE WHEN @AplicaOperadora > 0 THEN 0 ELSE 1 END AS PermitirCarga

END

select * from S_Proveedor where rfc in ('ITS071026QB1', 'PDO070403RJ8')