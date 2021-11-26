USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[AD_SP_ComboInstalaciones]    Script Date: 26/11/2021 01:44:37 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[AD_SP_ComboInstalaciones]
	@IdContrato INT

AS
BEGIN

	SELECT
		i.IdInstalacion,
		i.NombreInstalacion
    FROM Adinco.dbo.CO_Instalacion AS i (NOLOCK)
	 JOIN adinco.dbo.CO_Contrato AS c (NOLOCK) ON c.IdAreaContractual = i.IdAreaContractual and c.IdContrato = @IdContrato
	WHERE ISNULL(i.Activo,0) = 1
		
END
