-- =============================================
-- Author:		<Abel Rivera>
-- Modified date: <01-02-18>
-- Description:	<Elimina un cliente junto con sus respectivas relaciones que se hayan hecho en datos de contacto y finacieros>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EliminarRelacionFacturaCliente]
@IdRelacion INT,
@IdProveedor INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE  @RelacionCuentaBancaria TABLE (IdRow INT IDENTITY(1,1), IdCtaBancariaProveedor INT )
	DECLARE  @RelacionDatosContacto  TABLE (IdRow INT IDENTITY(1,1), IdContactoCS INT )

	INSERT INTO @RelacionCuentaBancaria   SELECT
	                                       --ROW_NUMBER() OVER(ORDER BY cbsc.IdCtaBancariaProveedor  ASC) AS Row#,
	                                       cbsc.IdCtaBancariaProveedor
	                                       FROM dbo.PV_CuentaBancariaSubContratista cbsc
										   INNER JOIN dbo.PV_ContratistaSubContratista csc
										   ON csc.IdSubContratista = cbsc.IdSubcontratista
										   INNER JOIN dbo.PV_CuentaBancaria cb 
										   ON cb.DatoBancarioID = cbsc.IdCuentaBancaria
										   WHERE csc.IdRelacion = @IdRelacion AND cbsc.IsActivo = 1 
										   AND cb.IdProveedor = @IdProveedor

										   --SELECT * FROM @RelacionCuentaBancaria

	  INSERT INTO @RelacionDatosContacto SELECT
									--ROW_NUMBER() OVER(ORDER BY ccsc.IdContactoCS  ASC) AS Row#,
									ccsc.IdContactoCS
									FROM S_ContactoContratistaSubContratista ccsc
									INNER JOIN dbo.PV_ContratistaSubContratista csc
									ON csc.IdRelacion = ccsc.IdContratistaSubContratista
									INNER JOIN dbo.S_Contacto_PA c 
									ON c.IdContacto = ccsc.IdContacto
									WHERE csc.IdRelacion = @IdRelacion AND ccsc.IsActivo = 1
									AND c.IdProveedor = @IdProveedor

		   DECLARE @counterCB INT = 1, @counterDC INT = 1
		   DECLARE @countCB INT = (SELECT COUNT(IdRow) FROM @RelacionCuentaBancaria),
		           @CountDC INT = (SELECT COUNT(IdRow) FROM @RelacionDatosContacto)

		   IF ( @countCB > 0 )
		   BEGIN		       
		       -- Cambiar estatus activo a 0 de las cuentas bancarias asociadas con el subcontratista
			   WHILE ( @counterCB <= @countCB )
			   BEGIN
					DECLARE @IdCuentaBancariaSubContratista INT = (SELECT IdCtaBancariaProveedor FROM @RelacionCuentaBancaria WHERE IdRow = @counterCB)	

					-- Se da de baja la relación de la cuenta bancaria
					UPDATE dbo.PV_CuentaBancariaSubContratista
					SET IsActivo = 0
					WHERE IdCtaBancariaProveedor = 	@IdCuentaBancariaSubContratista
					-- se da de baja el documento asociado con la relación
					UPDATE dbo.PV_DocumentoCuentaBancaria 
					SET IsActivo = 0
					WHERE IdCuentaBancaria = @IdCuentaBancariaSubContratista    

					SET @counterCB = @counterCB + 1
			   END
		   END

		   IF ( @CountDC > 0 )
		   BEGIN
				-- Cambiar estatus activo a 0 de los contactos asociados con un subcontratista
				WHILE ( @counterDC <= @CountDC )
				BEGIN
				    
					DECLARE @IdContactoCS INT = (SELECT IdContactoCS FROM @RelacionDatosContacto WHERE IdRow = @counterDC)

					UPDATE S_ContactoContratistaSubContratista 
					SET IsActivo = 0
					WHERE IdContactoCS = @IdContactoCS

					SET @counterDC = @counterDC + 1
				END

		   END

  -- Cambiar el estatus de la la relacion del contratista con el subcontratista
	update PV_ContratistaSubContratista
	set
	IsActivo = 0
	where IdRelacion = @IdRelacion

	select 'relación eliminada'

END
