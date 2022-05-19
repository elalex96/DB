
CREATE PROCEDURE [dbo].[EPT_RegistraImportaLayoutDetalle]--10007,10,10000,'20220401',12.3333,0
	@IdContrato INT,
	@IdUsuario INT,
	@ArchivoImportado VARCHAR(150),
	@Contratista VARCHAR(150),
	@IdentificadorDocumento VARCHAR(150),
	@Contrato VARCHAR(150),
	@NombreDocumento VARCHAR(150),
	@Mes VARCHAR(150),
	@Anio VARCHAR(150),
	@ImportacionLayoutId INT
AS
BEGIN
    SET NOCOUNT ON;
	IF(
		(SELECT COUNT(1)
				FROM 
					EPT_ImportacionLayout IL
				JOIN
					EPT_ImportacionLayoutDetalle ILD
					ON	IL.Id	=	ILD.ImportacionLayoutId
					AND	IL.ContratoId = @IdContrato
				WHERE 
					IL.ContratoId = @IdContrato
				AND
					ILD.Contratista = @Contratista
				AND	ILD.Contrato = @Contrato
				AND	ILD.IdentificadorDocumento = @IdentificadorDocumento
				AND	ILD.NombreDocumento = @NombreDocumento
				AND	ILD.Mes = @Mes
				AND	ILD.Anio = @Anio
			) <= 0 
		)
	BEGIN
		
             INSERT INTO EPT_ImportacionLayoutDetalle(ImportacionLayoutId,Contratista,Contrato,IdentificadorDocumento,NombreDocumento,Mes,Anio,CreadoEn)
			 VALUES (@ImportacionLayoutId,@Contratista,@Contrato,@IdentificadorDocumento,@NombreDocumento,@Mes,@Anio,GETDATE())
	END
	
END;