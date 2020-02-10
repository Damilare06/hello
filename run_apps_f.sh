APP1_EXEC=/lore/adesoa/dev/builds/hello/app1/app1_f
CPL_EXEC=/lore/adesoa/dev/builds/hello/cpl_exec
APP2_EXEC=/lore/adesoa/dev/builds/hello/app2/app2



OUTFILE=cpl_f.out

mpirun -np 4 ${CPL_EXEC} &> ${OUTFILE}  &



OUTFILE=app1_f.out

mpirun -np 4 ${APP1_EXEC} &> ${OUTFILE}  &


OUTFILE=app2_f.out


mpirun -np 4 ${APP2_EXEC} &> ${OUTFILE} &


wait

echo $(date)
