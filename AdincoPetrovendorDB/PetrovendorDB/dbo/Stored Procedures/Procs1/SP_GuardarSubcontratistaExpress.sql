CREATE PROCEDURE [dbo].[SP_GuardarSubcontratistaExpress]
(
    @RFC NVARCHAR(MAX),
    @RazonSocial NVARCHAR(MAX),
	@IdNacionalidad INT
)
AS
BEGIN

	DECLARE @IdProveedor INT 
	DECLARE @IdTipoRegistro  INT = 1 --Por Factura 
    INSERT INTO dbo.S_Proveedor
    (
        RFC,
        RazonSocial,
		Activo,
        IdNacionalidad,
		IsEliminado,
		RegimenCapital

    )
    VALUES
    (  
        @RFC,        -- RFC - varchar(30)
        @RazonSocial,     -- RazonSocial - nvarchar(max)
		0,
		@IdNacionalidad,
		0,
		''
    )
    
	--retorno el Idproveedor insertado
	SET @IdProveedor = (SELECT @@IDENTITY)

	INSERT INTO  dbo.S_ModoRegistroProveedor
	(
	    IdProveedor,
	    IdModoRegistro,
	    FechaRegistro
	)
	VALUES
	(   @IdProveedor,        -- IdProveedor - int
	    @IdTipoRegistro,        -- IdModoRegistro - int Factura
	    GETDATE() -- FechaRegistro - datetime
	    )

		SELECT @IdProveedor
END
 
