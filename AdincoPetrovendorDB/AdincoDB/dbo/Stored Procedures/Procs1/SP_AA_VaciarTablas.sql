-- =============================================
-- Author:		Manuel CD
-- Create date: 10-10-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_AA_VaciarTablas] --10010,34,10,2017
	-- Add the parameters for the stored procedure here
@IdContrato INT,
@IdHoja     INT,
@Mes        INT,
@Anio       INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;
             --SELECT CAST(@IdContrato AS INT);
             DECLARE @NomContrato NVARCHAR(50);
             SELECT @NomContrato = NumeroContrato
             FROM dbo.CO_Contrato
             WHERE IdContrato = @IdContrato;
	--SELECT @NomContrato

    -- Insert statements for procedure here
             IF(@IdHoja = 53)
                 BEGIN
                     DELETE dbo.AA_FMP_53
                     WHERE [ID del contrato asignado por CNH (RF01_01)] = @NomContrato;
                 END;
             IF(@IdHoja = 54)
                 BEGIN
                     DELETE dbo.AA_FMP_54
                     WHERE [ID del contrato asignado por CNH (RF01_01)] = @NomContrato;
                 END;
             IF(@IdHoja = 32)
                 BEGIN
                     DELETE dbo.AA_RMP_CONT_32
                     WHERE [RF01_01] = @NomContrato AND RMPCT32_00 = @Mes AND RMPCT32_01 = @Anio;
                 END;
             IF(@IdHoja = 33)
                 BEGIN
                     DELETE dbo.AA_RMP_CONT_33
                     WHERE [RF01_01] = @NomContrato AND RMPCT33_00 = @Mes AND RMPCT33_01 = @Anio;
                 END;
             IF(@IdHoja = 34)
                 BEGIN
				 SET LANGUAGE SPANISH
				 DELETE AA_RMP_CONT_34 
				 WHERE [RF01_01] = @NomContrato AND MONTH(CONVERT(DATE, [RMPCT34_00])) = @Mes AND YEAR(CONVERT(DATE, [RMPCT34_00])) = @Anio AND LEN([RMPCT34_00]) = 10;
                 END;
             IF(@IdHoja = 35)
                 BEGIN
                     DELETE dbo.AA_RMP_CONT_35
                     WHERE [RF01_01] = @NomContrato AND RMPCT35_00 = @Mes AND RMPCT35_01= @Anio;
                 END;

	    IF @@ERROR <> 0
             SELECT 'false' AS msj;
         ELSE
		   SELECT 'true' AS msj;

         END;
