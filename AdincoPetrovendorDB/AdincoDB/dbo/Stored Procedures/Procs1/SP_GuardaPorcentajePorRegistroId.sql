
CREATE PROCEDURE [dbo].[SP_GuardaPorcentajePorRegistroId]
@IdContrato  INT,     
@IdUsuario     INT,
@RegistroId     INT,
@Porcentaje FLOAT,
@MontoRegistro FLOAT
AS    
     BEGIN       
         SET NOCOUNT ON;
		 
		 DECLARE @MontoEquivalente FLOAT = 0, @ContratoArea VARCHAR(MAX)='';

		 SELECT @MontoEquivalente = (@MontoRegistro * @Porcentaje/100);

		 SELECT @ContratoArea =
		 	AC.NombreAreaContractual
		 FROM 
			CO_Contrato C
		JOIN
			CO_AreaContractual	AC
			ON	C.IdAreaContractual	=	AC.IdAreaContractual
		WHERE	C.IdContrato	=	@IdContrato;

		IF(@ContratoArea = 'Amatitlán')
		BEGIN
			IF( (SELECT COUNT(1) FROM [CO_RegistroMarkup] WHERE GastoId = @RegistroId) > 0)
		BEGIN
			UPDATE [CO_RegistroMarkup]
			SET	
				Porcentaje = @Porcentaje,
				MontoEquivalente = @MontoEquivalente,
				MontoGasto = @MontoRegistro,
				Activo = 1,
				ModificadoPor = @IdUsuario,
				ModificadoEn	=	GETDATE(),
				ContratoId	=	@IdContrato
			WHERE GastoId = @RegistroId
		END
		ELSE
		BEGIN
			INSERT  INTO [CO_RegistroMarkup](	GastoId,
												Porcentaje,
												MontoEquivalente,
												MontoGasto,
												Activo,
												CreadoPor,
												CreadoEn,
												ContratoId)
												VALUES(
												
												@RegistroId,
												@Porcentaje,
												@MontoEquivalente,
												@MontoRegistro,
												1,
												@IdUsuario,
												GETDATE(),
												@IdContrato)
		END
		END
END
