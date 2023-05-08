create PROC p_SIPAC_ImportBitacora_INS
@Id INT out,
@IdContrato int,
@NombreArchivo varchar(1000),
@FechaCarga datetime,
@IdAWSExcel int,
@MesReporte date,
@CreadoPor int
AS
BEGIN

		INSERT INTO [dbo].[SIPAC_ImportBitacora]
				   ([NombreArchivo]
					,IdContrato
				   ,[FechaCarga]
				   ,[IdAWSExcel]
				   ,[MesReporte]
				   ,[CreadoPor])
			 VALUES
				   (@NombreArchivo, 
				   @IdContrato,
				   @FechaCarga, 
				   @IdAWSExcel, 
				   @MesReporte, 
				   @CreadoPor)

		set @Id = SCOPE_IDENTITY()
END


