-- =============================================
-- Author:	Reyna Olvera
-- Create date:25/06
-- Description:	Extrae las actividades
-- =============================================
CREATE PROCEDURE dbo.sp_FI_ExtraeErroresFacturas --3,10061,11107,12107--10010,10061,10011
    @idContrato INT,
    @idUsuario INT,
    @Error VARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FI_ErroresCargaFactura
    (
        Error,
        IdContrato,
        CreadoPor,
        CreadoEl,
        ModificadoPor,
        ModificadoEl,
        Activo
    )
    VALUES
    (@Error, @idContrato, @idUsuario, GETDATE(), @idUsuario, GETDATE(), 1);

	IF( @Error LIKE '%existe%')
	BEGIN 
	--SELECT REPLACE( @Error,'Error:Excepción: La factura que desea insertar ya existe UUID: ','')  AS error;

  SELECT '<div class="alert alert-danger alert-dismissable">
<button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>
                                 <strong>Alerta! </strong>' +REPLACE( @Error,'Excepción:','')+ ', en el contrato' +C.NumeroContrato+ ' </div>' AS error
								 FROM dbo.FI_Factura F
								 JOIN dbo.CO_Contrato C ON f.IdContrato=C.IdContrato
								 where F.UUID=REPLACE( @Error,'Error:Excepción: La factura que desea insertar ya existe UUID: ','') ;
								 
	END
	ELSE
	SELECT '<div class="alert alert-danger alert-dismissable">
<button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>
                                 <strong>Alerta! </strong>' +REPLACE( @Error,'Excepción:','') + ' </div>' AS error;



END;