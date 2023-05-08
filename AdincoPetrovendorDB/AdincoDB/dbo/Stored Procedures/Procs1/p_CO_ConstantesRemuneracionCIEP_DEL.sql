CREATE PROC p_CO_ConstantesRemuneracionCIEP_DEL
@IdConstantesRemuneracionCIEP	int
AS


	DELETE CO_ConstantesRemuneracionCIEP		
	WHERE IdConstantesRemuneracionCIEP = @IdConstantesRemuneracionCIEP