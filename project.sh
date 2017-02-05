source_name="boilerplate"
source_module="Boilerplate"

target_name=${1:?project dirname}
target_module=${2:?project module name}

mv lib/boilerplate lib/${target_name}
mv lib/boilerplate.rb lib/${target_name}.rb

grep -lir boilerplate . | while read filename; do
  sed -i.bkp -r "s/${source_name}/${target_name}/" "${filename}"
  sed -i.bkp -r "s/${source_module}/${target_module}/" "${filename}"
done
